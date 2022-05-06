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
    Nix.print(io, fetcher.args; sort=true)
    return nothing
end

Base.@kwdef mutable struct RegistryInfo
    name::String
    uuid::UUID
    url::String
    path::String
end

function collect_registries()
    map(Pkg.Types.collect_registries()) do regspec
        RegistryInfo(; regspec.name, uuid=UUID(regspec.uuid), regspec.url, regspec.path)
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
