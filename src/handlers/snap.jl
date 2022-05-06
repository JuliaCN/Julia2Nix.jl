const SNAP_SCHEMA = SchemaSet(
    SimpleSchema("name", String, true),
    SimpleSchema("channel", String, true),
)

# TODO add test for asset handling
function snap_handler(name::AbstractString, spec::AbstractDict)
    name = spec["name"]
    channel = spec["channel"]
    
    info = snap_api_get("/snaps/details/$(name)", query=Dict("channel" => channel))
    ver = info["version"]
    rev = info["revision"]
    sha512 = info["download_sha512"]
    url = info["download_url"]

    fetcher_name = "pkgs.fetchurl"
    fetcher_args = Dict{Symbol,Any}()
    fetcher_args[:name] = sanitize_name("$(name)-$(ver)")
    fetcher_args[:url] = url
    fetcher_args[:sha512] = sha512

    return Source(;pname=name, version=ver, fetcher_name, fetcher_args)
end

function snap_api_get(endpoint; kwargs...)
    url = "https://api.snapcraft.io/api/v1/$(lstrip(endpoint, ['/']))"
    headers = Dict("X-Ubuntu-Series" => 16)
    return JSON.parse(String(HTTP.get(url, headers; kwargs...).body))
end
