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
using CodecZlib
using Tar

using ..Julia2Nix
using ..Julia2Nix: run_suppress

const PKGS_ARCHIVE_FETCHER = "pkgs.fetchzip"
const PKGS_GIT_FETCHER = "pkgs.fetchgit"

const BUILTINS_ARCHIVE_FETCHER = "builtins.fetchTarball"
const BUILTINS_GIT_FETCHER = "builtins.fetchGit"

const ARCHIVE_FETCHER = PKGS_ARCHIVE_FETCHER
const GIT_FETCHER = BUILTINS_GIT_FETCHER

include("./types.jl")
include("./util.jl")
include("./fetch.jl")

"""
    load_registries!(pkgs::Vector{PackageInfo})

Load registries from `Registry.toml`.
"""
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

"""
    load_artifacts!(pkginfo::PackageInfo)

Write meta to `PackageInfo` from toml
"""
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

"""
    generate_depot(registry_fetchers, pkg_fetchers ,artifact_fetchers)

generate `depot` by `registry` `pkg` and `artifact`
"""
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

"""
    write_julia2nix(depot, opts, package_path, name)

Write `julia2nix.toml` to `out_path`
"""
function write_julia2nix(
    depot::Dict{String,Fetcher},
    opts::Options,
    package_path::String,
    out_path::String,
    name::String,
)
    io = IOBuffer(; append = true)
    for path in sort(collect(keys(depot)))
        _, fetch = split(depot[path].name, ".")
        write(io, "[", fetch, ".", depot[path].args["name"], "]\n")
        TOML.print(io, Dict("name" => path))

        for (k, v) in depot[path].args
            if k != "name"
                v = typeof(v) == Base.SHA1 ? string(v) : v
                TOML.print(io, Dict(k => v))
            end
        end
        write(io, "\n")
    end

    toml = TOML.parse(io)

    arch, os = get_os_from_opts(opts)
    platform = arch * '-' * os
    toml = Dict("depot" => Dict(platform => toml))

    depotfile_path = normpath(joinpath(package_path, "julia2nix.toml"))

    @info "Writing depot to $depotfile_path"
    open(normpath(joinpath(out_path, name)), "w") do f
        origin = TOML.parse(f)
        if haskey(origin, "depot")
            origin["depot"][platform] = toml["depot"][platform]
        else
            origin = toml
        end
        TOML.print(f, origin)
    end
end

function main(
    package_path::String,
    name::String,
    opts::Options = Options(),
    out_path::String = package_path,
)
    if opts.pkg_server !== nothing
        ENV["JULIA_PKG_SERVER"] = opts.pkg_server
        @assert Pkg.pkg_server() == opts.pkg_server
    end

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
        write_julia2nix(depot, opts, package_path, out_path, name)
        return pkgs
    end
end

end
