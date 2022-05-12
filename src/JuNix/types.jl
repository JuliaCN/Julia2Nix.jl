struct Fetcher
    name::String
    args::Dict{String,Any}
end

const FetcherResult = Union{Fetcher,Nothing}

function Base.show(io::IO, fetcher::Fetcher)
    print(io, "nix-prefetch ", fetcher.name, " ", join(parse_fetcher(fetcher), " "))
    return nothing
end

function Nix.print(io::IO, fetcher::Fetcher)
    print(io, fetcher.name, " ")
    Nix.print(io, fetcher.args; sort = true)
    return nothing
end

Base.@kwdef mutable struct RegistryInfo
    name::String
    uuid::UUID
    url::String
    path::String
end

# Old registry might use "url" while new registry uses "repo"
function collect_registries()
    registry_instances = if VERSION >= v"1.7.0"
        # https://github.com/JuliaLang/Pkg.jl/pull/2072
        Pkg.Registry.reachable_registries()
    else
        Pkg.Types.collect_registries()
    end
    # Julia 1.7 supports in-memory tarball reading
    for regspec in registry_instances
        tarball_path = get_tarball_registry_path(regspec.path)
        isnothing(tarball_path) && continue
        reg_dir = joinpath(dirname(regspec.path), regspec.name)
        isdir(reg_dir) && continue
        # if the registry tarball is not yet extracted, do it here so that
        # future operations don't need to handle different scenarios
        extract_tarball(tarball_path, reg_dir)
    end
    map(registry_instances) do regspec
        repo = hasfield(typeof(regspec), :repo) ? regspec.repo : nothing
        url = something(regspec.url, repo)
        path = if isnothing(get_tarball_registry_path(regspec.path))
            regspec.path
        else
            joinpath(dirname(regspec.path), regspec.name)
        end
        RegistryInfo(; regspec.name, uuid = UUID(regspec.uuid), url, path)
    end
end

function get_tarball_registry_path(path)
    endswith(path, ".toml") || return nothing
    regspec = TOML.parsefile(path)
    tarball_name = regspec["path"]
    endswith(tarball_name, "tar.gz") || return nothing
    tarball_path = joinpath(dirname(path), tarball_name)
    isfile(tarball_path) || return nothing
    return tarball_path
end

function extract_tarball(tarball_path, dir)
    open(tarball_path) do tar_gz
        tar = GzipDecompressorStream(tar_gz)
        Tar.extract(tar, dir)
    end
end

function registry_relpath(reg::RegistryInfo)
    reg = realpath(reg.path)
    for depot in DEPOT_PATH
        depot = realpath(depot)
        startswith(reg, depot) && return relpath(reg, depot)
    end
    return error("Could not locate $(reg.name) in $DEPOT_PATH")
end

Base.@kwdef mutable struct ArtifactInfo
    name::String
    tree_hash::SHA1
    path::String = "artifacts/$tree_hash"
    arch::Union{String,Nothing} = nothing
    os::Union{String,Nothing} = nothing
    libc::Union{String,Nothing} = nothing
    lazy::Bool = false
    downloads::Vector{NamedTuple{(:url, :sha256),Tuple{Int64,Int64}}} = []
end

Base.@kwdef mutable struct PackageInfo
    name::String
    uuid::UUID
    version::VersionNumber
    tree_hash::SHA1
    depot::String
    path::String
    is_tracking_path::Bool
    is_tracking_repo::Bool
    is_tracking_registry::Bool
    registries::Vector{RegistryInfo} = RegistrySpec[]
    artifacts::Dict{String,Vector{ArtifactInfo}} = Dict{String,Vector{ArtifactInfo}}()
    repos::Vector{String} = String[]
    archives::Vector{String} = String[]
end

Base.@kwdef struct Options
    nworkers::Int = 1
    arch::Union{Set{String},Nothing} = nothing
    os::Union{Set{String},Nothing} = nothing
    libc::Union{Set{String},Nothing} = nothing
    lazy_artifacts::Bool = false
    pkg_server::Union{String,Nothing} = pkg_server()
    force_overwrite::Bool = false
    check_store::Bool = false
end
