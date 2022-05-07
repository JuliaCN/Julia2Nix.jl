module JuNix

# NOTE
# Nix sha256 is base-32 encoded
# Artifact sha256 is base-16 encoded
#   nix-hash --type sha256 --to-base16 <HASH>
# If 'name' is left as 'source' for 'fetchzip'
# things go a lot slower??? Passing a name for now

using Pkg
using Pkg.Registry
using Pkg: pkg_server
using Pkg.Types: Context, VersionNumber
using Pkg.MiniProgressBars
using TOML
using HTTP
using Base: UUID, SHA1
using LibGit2

using ..julia2nix
using ..julia2nix: run_suppress

const PKGS_ARCHIVE_FETCHER = "pkgs.fetchzip"
const PKGS_GIT_FETCHER = "pkgs.fetchgit"

const BUILTINS_ARCHIVE_FETCHER = "builtins.fetchTarball"
const BUILTINS_GIT_FETCHER = "builtins.fetchGit"

const ARCHIVE_FETCHER = PKGS_ARCHIVE_FETCHER
const GIT_FETCHER = BUILTINS_GIT_FETCHER

include("./types.jl")
include("./util.jl")
include("./fetch.jl")

function load_registries!(pkgs::Vector{PackageInfo})
    for reg in collect_registries()
        known = TOML.parsefile(joinpath(reg.path, "Registry.toml"))["packages"]
        for pkg in pkgs
            if pkg.is_tracking_registry
                uuid = string(pkg.uuid)
                if haskey(known, uuid)
                    meta = TOML.parsefile(
                        joinpath(reg.path, known[uuid]["path"], "Package.toml"),
                    )
                    push!(pkg.repos, meta["repo"])
                    push!(pkg.registries, reg)
                end
            end
        end
    end
    return pkgs
end

function load_artifacts!(pkginfo::PackageInfo)
    artifacts_file =
        Pkg.Artifacts.find_artifacts_toml(joinpath(pkginfo.depot, pkginfo.path))
    if artifacts_file !== nothing
        artifacts_meta = TOML.parsefile(artifacts_file)
        for (name, metas) in artifacts_meta
            if metas isa AbstractDict
                metas = [metas]
            end
            pkginfo.artifacts[name] = ArtifactInfo[]
            for meta in metas
                artifactinfo = ArtifactInfo(;
                    name,
                    tree_hash = SHA1(meta["git-tree-sha1"]),
                    arch = get(meta, "arch", nothing),
                    os = get(meta, "os", nothing),
                    libc = get(meta, "libc", nothing),
                    lazy = get(meta, "lazy", false),
                    downloads = map(
                        d -> (url = d["url"], sha256 = d["sha256"]),
                        get(meta, "downloads", []),
                    ),
                )
                push!(pkginfo.artifacts[name], artifactinfo)
            end
        end
    end
    return pkginfo
end


function load_packages(ctx::Context)
    alldeps = Pkg.dependencies(ctx.env)
    pkgs = PackageInfo[]
    for (uuid, pkgspec) in alldeps
        # TODO version from Project.toml?
        if Pkg.Types.is_stdlib(uuid, VERSION)
            continue
        elseif pkgspec.is_tracking_path
            error("Package $(pkgspec.name) ($(uuid)) is tracking a path")
        else
            tree_hash = SHA1(pkgspec.tree_hash)
            depot, path = get_source_path(ctx, pkgspec.name, uuid, tree_hash)
            pkg = PackageInfo(;
                uuid,
                pkgspec.name,
                pkgspec.version,
                tree_hash,
                depot,
                path,
                pkgspec.is_tracking_path,
                pkgspec.is_tracking_repo,
                pkgspec.is_tracking_registry,
            )
            if pkg.is_tracking_repo
                push!(pkg.repos, pkgspec.git_source)
            end

            load_artifacts!(pkg)

            push!(pkgs, pkg)
        end
    end

    load_registries!(pkgs)

    return pkgs
end

function generate_depot(
    registry_fetchers::Dict{RegistryInfo,FetcherResult},
    pkg_fetchers::Dict{PackageInfo,FetcherResult},
    artifact_fetchers::Dict{ArtifactInfo,FetcherResult},
)
    depot = Dict{String,Fetcher}()
    for (reg, fetcher) in registry_fetchers
        path = registry_relpath(reg)
        @assert !haskey(depot, path)
        depot[path] = fetcher
    end
    for (pkg, fetcher) in pkg_fetchers
        @assert !haskey(depot, pkg.path)
        depot[pkg.path] = fetcher
    end
    for (artifact, fetcher) in artifact_fetchers
        @assert !haskey(depot, artifact.path)
        depot[artifact.path] = fetcher
    end
    return depot
end

function write_depot(
    depot::Dict{String,Fetcher},
    meta::Dict{String,Any},
    opts::Options,
    package_path::String,
    out_path::String,
)
    io = IOBuffer(; append = true)
    write(io, "{ pkgs ? import <nixpkgs> {} }: {\n")
    write(io, "meta = ")
    Nix.print(io, meta)
    write(io, ";\n")
    write(io, "depot = {")
    for path in sort(collect(keys(depot)))
        Nix.print(io, path)
        write(io, " = (")
        Nix.print(io, depot[path])
        write(io, ");\n")
    end
    write(io, "};\n")
    write(io, '}')

    depotfile_path = normpath(joinpath(package_path, "Depot.nix"))
    if ispath(depotfile_path) && !opts.force_overwrite
        error("$depotfile_path already exists!")
    else
        @info "Writing depot to $depotfile_path"
        open(normpath(joinpath(out_path, "Depot.nix")), "w") do f
            Nix.nixfmt(f, io)
        end
    end
end

function main(package_path::String, opts::Options = Options())
    if opts.pkg_server !== nothing
        ENV["JULIA_PKG_SERVER"] = opts.pkg_server
        @assert Pkg.pkg_server() == opts.pkg_server
    end

    meta = Dict{String,Any}("pkgServer" => opts.pkg_server)

    Pkg.Operations.with_temp_env(package_path) do
        ctx = Context()
        pkgs = load_packages(ctx)

        @info "Fetching registries..."
        registry_fetchers = select_registry_fetchers(opts)

        @info "Fetching packages..."
        pkg_fetchers = select_pkg_fetchers(pkgs, opts)

        @info "Fetching artifacts..."
        artifact_fetchers = select_artifact_fetchers(pkgs, opts)

        depot = generate_depot(registry_fetchers, pkg_fetchers, artifact_fetchers)
        write_depot(depot, meta, opts, package_path, out_path)
        return pkgs
    end
end

end
