const CRATE_SCHEMA = SchemaSet(
    SimpleSchema("pname", String, true),
    SimpleSchema("version", String, true),
    SimpleSchema("extraArgs", Dict, false),
)

const CRATES_IO_BASE_URL = "https://crates.io/api/v1/crates"

function crate_handler(name::AbstractString, spec::AbstractDict)
    pname = spec["pname"]
    version = parse_crate_version(pname, spec["version"])
    extraArgs = get(spec, "extraArgs", Dict())

    new_spec = subset(spec, keys(DEFAULT_SCHEMA_SET)...)
    new_spec["name"] = sanitize_name(get(spec, "name", "$(pname)-$(version)"))
    new_spec["url"] = crate_tarball_url(pname, version)
    new_spec["extraArgs"] = extraArgs

    source = archive_handler(name, new_spec)

    return Source(;
        pname, version, fetcher_name=source.fetcher_name, fetcher_args=source.fetcher_args
    )
end

function parse_crate_version(pname::AbstractString, version::AbstractString)
    if version == "stable"
        version = crate_metadata(pname)["crate"]["max_stable_version"]
    elseif version == "latest"
        version = crate_metadata(pname)["crate"]["max_version"]
    end
    return version
end

function crate_metadata(pname::AbstractString)
    return JSON.parse(String(HTTP.get("$(CRATES_IO_BASE_URL)/$(pname)").body))
end

function crate_tarball_url(pname::AbstractString, version::AbstractString)
    return "$(CRATES_IO_BASE_URL)/$(pname)/$(version)/download#crate.tar.gz"
end
