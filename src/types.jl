####
#### Julia2NixError
####

struct Julia2NixError <: Exception
    msg::String
end

nixsourcerer_error(msg::String...) = throw(Julia2NixError(join(msg)))

Base.showerror(io::IO, err::Julia2NixError) = print(io, err.msg)

####
#### Fetcher 
####

# TODO merge Fetcher and Source?

mutable struct Fetcher
    name::String
    args::Dict{Symbol,Any}
end

function Nix.print(io::IO, fetcher::Fetcher)
    dict = Dict(
        :fetcher => Nix.NixText(fetcher.name),
        :fetcherName => fetcher.name,
        :fetcherArgs => fetcher.args,
        :outPath => Nix.NixText("fetcher fetcherArgs"),
    )
    write(io, "let ")
    for pair in dict
        Nix.print(io, pair)
    end
    write(io, "in { inherit ")
    for var in keys(dict)
        write(io, ' ')
        Nix.print(io, var)
    end
    return write(io, "; }")
end

####
#### Source
####

# const SOURCE_KEYMAP = Dict(
#     "pname" => "pname",
#     "version" => "version",
#     "name" => "name",
#     "fetcher_name" => "fetcherName",
#     "fetcher_args" => "fetcherArgs",
#     "meta" => "meta",
# )

mutable struct Source
    pname::String
    version::String
    name::String
    fetcher_name::String
    fetcher_args::Dict{Symbol,Any}
    meta::Dict{String,Any}
    outPath::Union{String,Nothing}
    function Source(
        pname::AbstractString,
        version::Union{<:AbstractString,VersionNumber},
        name::AbstractString,
        fetcher_name::AbstractString,
        fetcher_args::AbstractDict,
        meta::AbstractDict,
        outPath::Union{<:AbstractString,Nothing},
    )
        return new(
            strip(pname),
            strip(string(version)),
            strip(name),
            strip(fetcher_name),
            fetcher_args,
            meta,
            outPath === nothing ? outPath : strip(outPath),
        )
    end

end

function Source(;
    pname,
    version,
    name = "$(pname)-$(version)",
    fetcher_name,
    fetcher_args,
    meta = Dict{String,Any}(),
    outPath = nothing,
)
    return Source(pname, version, name, fetcher_name, fetcher_args, meta, outPath)
end

function Nix.print(io::IO, source::Source)
    dict = Dict(
        :name => source.name,
        :pname => source.pname,
        :version => source.version,
        :fetcher => Nix.NixText(source.fetcher_name),
        :fetcherName => source.fetcher_name,
        :fetcherArgs => source.fetcher_args,
        :outPath => Nix.NixText("fetcher fetcherArgs"),
        :meta => source.meta,
    )
    write(io, "let ")
    for pair in dict
        Nix.print(io, pair)
    end
    write(io, "in { inherit ")
    for var in keys(dict)
        write(io, ' ')
        Nix.print(io, var)
    end
    return write(io, "; }")
end

####
#### Schemas
####

abstract type Schema end

struct SimpleSchema <: Schema
    key::String
    type::Type
    required::Bool
end

Base.keys(schema::SimpleSchema) = (schema.key,)

function validate(schema::SimpleSchema, spec)
    key = schema.key
    if haskey(spec, key)
        T = schema.type
        V = typeof(spec[key])
        if !(V <: T)
            nixsourcerer_error("Expected key \"$key\" to be of type $T, got $V")
        end
    elseif schema.required
        nixsourcerer_error("Must specify \"$key\"")
    end
end

struct ExclusiveSchema{N} <: Schema
    keys::NTuple{N,String}
    types::NTuple{N,Type}
    required::Bool
end

Base.keys(schema::ExclusiveSchema) = schema.keys

function validate(schema::ExclusiveSchema, spec)
    idx = findfirst(k -> haskey(spec, k), schema.keys)
    if idx !== nothing
        key = schema.keys[idx]
        T = schema.types[idx]
        V = typeof(spec[key])
        if !(V <: T)
            nixsourcerer_error("Expected key \"$key\" to be of type $T, got $V.")
        end
    elseif schema.required
        nixsourcerer_error("Must specify exactly one of \"$(schema.keys)\".")
    end
end

struct DependentSchema{N} <: Schema
    ikey::String
    itype::Type
    dkeys::NTuple{N,String}
    dtypes::NTuple{N,Type}
    required::Bool
end

Base.keys(schema::DependentSchema) = (schema.ikey, schema.dkeys...)

function validate(schema::DependentSchema, spec)
    if schema.required && !haskey(spec, schema.ikey)
        nixsourcerer_error("Must specify \"$(schema.ikey)\"")
    elseif haskey(spec, schema.ikey)
        T = schema.itype
        V = typeof(spec[schema.ikey])
        V <: T ||
            nixsourcerer_error("Expected key \"$(schema.ikey)\" to be of type $T, got $V.")
        for (dkey, T) in zip(schema.dkeys, schema.dtypes)
            haskey(spec, dkey) || nixsourcerer_error(
                "Must specify \"$(schema.dkeys)\" if providing \"$(schema.ikey)\"",
            )
            V = typeof(spec[dkey])
            V <: T || nixsourcerer_error("Expected key \"$dkey\" to be of type $T, got $V.")
        end
    end
end

struct SchemaSet{N} <: Schema
    schemas::NTuple{N,Schema}
end

SchemaSet(schemas::Schema...) = SchemaSet(schemas)

Base.keys(schema::SchemaSet) =
    foldl((a, b) -> (a..., keys(b)...), schema.schemas; init = ())

const DEFAULT_SCHEMA_SET = SchemaSet(
    SimpleSchema("type", String, true),
    SimpleSchema("builtin", Bool, false),
    SimpleSchema("meta", Dict, false),
)

function validate(set::SchemaSet, spec)
    augmented = SchemaSet(DEFAULT_SCHEMA_SET.schemas..., set.schemas...)
    check_unknown_keys(augmented, spec)
    for schema in augmented.schemas
        validate(schema, spec)
    end
end

function check_unknown_keys(set::SchemaSet, spec)
    unknown = setdiff(keys(spec), keys(set))
    if length(unknown) > 0
        nixsourcerer_error("Unknown key(s): $(Tuple(unknown))")
    end
end

####
#### Project
####

# TODO it's weird that manifest is .meta but project is dict

struct Project
    specs::Dict{String,Any}
end

Project() = Project(Dict{String,Any}())

function validate(project::Project)
    for (name, spec) in project.specs
        try
            if !haskey(spec, "type")
                nixsourcerer_error("\"type\" not specified")
            elseif !haskey(SCHEMAS, spec["type"])
                nixsourcerer_error("Unknown type \"$(spec["type"])\"")
            else
                validate(SCHEMAS[spec["type"]], spec)
            end
        catch e
            nixsourcerer_error("Could not parse spec \"$name\": ", sprint(showerror, e))
            rethrow()
        end
    end
end

function read_project(project_file::AbstractString = PROJECT_FILENAME)
    raw = TOML.parsefile(project_file)
    # TODO hack
    for v in values(raw)
        v["meta"] = get(v, "meta", Dict())
    end
    return Project(raw)
end

function write_project(project::Project, project_file::AbstractString = PROJECT_FILENAME)
    open(project_file, "w") do io
        TOML.print(io, project.specs)
    end
end

####
#### Manifest
####

struct Manifest
    sources::Dict{String,Source}
end

Manifest() = Manifest(Dict{String,Source}())

function validate(manifest::Manifest) end

function read_manifest(manifest_file::AbstractString = MANIFEST_FILENAME)
    manifest_file = abspath(manifest_file)
    attrs = ["pname", "version", "name", "fetcherName", "fetcherArgs", "meta", "outPath"]
    expr = """
        with builtins;
        let
        pkgs = import <nixpkgs> { };
        inherit (pkgs) lib;
        attrs = [$(join(map(s -> "\"$(s)\"", attrs), " "))];
        manifest = import $(manifest_file) { inherit pkgs; };
        in
        lib.mapAttrs
            (pkgname: pkg:
            builtins.listToAttrs (map
                (attr:
                    let value = pkg."\${attr}";
                    in
                    if attr == "outPath" then
                        { name = "_outPath"; value = builtins.toString value; }
                    else
                        { name = attr; inherit value; } 
                )
                attrs)
            )
            manifest
    """
    json =
        JSON.parse(strip(run_suppress(`nix eval --impure --json --expr $expr`; out = true)))

    manifest = Manifest()
    for (name, source) in json
        args = []
        for k in attrs
            if k == "fetcherArgs"
                fetcher_args = Dict{Symbol,Any}()
                for (k, v) in source[k]
                    fetcher_args[Symbol(k)] = v
                end
                push!(args, fetcher_args)
            elseif k == "outPath"
                push!(args, source["_outPath"])
            else
                push!(args, source[k])
            end
        end
        manifest.sources[name] = Source(args...)
    end

    return manifest
end

function write_manifest(
    manifest::Manifest,
    manifest_file::AbstractString = MANIFEST_FILENAME,
)
    io = IOBuffer(; append = true)
    write(io, "{ pkgs ? import <nixpkgs> {} }:")
    Nix.print(io, manifest.sources; sort = true)
    open(manifest_file, "w") do f
        Nix.nixpkgs_fmt(f, io)
    end
end

####
#### Package
####

mutable struct Package
    project::Project
    manifest::Manifest
    project_file::String
    manifest_file::String
end

function validate(package::Package)
    validate(package.project)
    return validate(package.manifest)
end

function read_package(path::AbstractString)
    project_file = get_project(path)
    manifest_file = get_manifest(path)
    manifest = isfile(manifest_file) ? read_manifest(manifest_file) : Manifest()
    return Package(read_project(project_file), manifest, project_file, manifest_file)
end

function write_package(package::Package)
    # TODO sort keys?
    # write_project(package.project, package.project_file)
    for name in keys(package.manifest.sources)
        if !haskey(package.project.specs, name)
            delete!(package.manifest.sources, name)
        end
    end
    return write_manifest(package.manifest, package.manifest_file)
end
