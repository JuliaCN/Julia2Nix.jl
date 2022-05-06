const FILE_SCHEMA = SchemaSet(
    SimpleSchema("url", String, true), 
    SimpleSchema("variables", Dict, false),
    SimpleSchema("extraArgs", Dict, false),
)

function file_handler(name::AbstractString, spec::AbstractDict)
    builtin = get(spec, "builtin", false)
    variables = get(spec, "variables", Dict())
    url = replace_variables(spec["url"], variables)
    meta = Dict("variables" => variables)
    extraArgs = get(spec, "extraArgs", Dict())

    fetcher_name = builtin ? "builtins.fetchurl" : "pkgs.fetchurl"
    fetcher_args = Dict{Symbol,Any}(Symbol(k) => v for (k,v) in extraArgs)
    fetcher_args[:name] = sanitize_name(get(spec, "name", url_name(spec["url"])))
    fetcher_args[:url] = url 
    
    hash = get_sha256(fetcher_name, fetcher_args)
    version = version_string(hash) 

    if builtin
        fetcher_args[:sha256] = string(hash, encoding=Base32Nix())
    else
        fetcher_args[:hash] = string(hash) 
    end


    return Source(; pname=name, version, fetcher_name, fetcher_args, meta)
end
