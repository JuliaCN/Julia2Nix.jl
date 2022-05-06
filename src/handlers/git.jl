# TODO allow ref to be sourceified

const GIT_SCHEMA = SchemaSet(
    SimpleSchema("url", String, true),
    ExclusiveSchema(("rev", "branch", "tag", "latest_semver_tag"), (String, String, String, Bool), true),
    SimpleSchema("submodule", Bool, false),
    SimpleSchema("variables", Dict, false),
    SimpleSchema("extraArgs", Dict, false),
)

function git_handler(name, spec)
    # NOTE pkgs.fetchgit appears to be faster because shallow clone
    builtin = get(spec, "builtin", false)
    submodule = get(spec, "submodule", false)
    variables = get(spec, "variables", Dict())
    url = replace_variables(spec["url"], variables) 
    meta = Dict{String,Any}("variables" => variables)
    extraArgs = get(spec, "extraArgs", Dict())
    
    if haskey(spec, "rev")
        # TODO is this correct when not sourceifying commit? 
        # It's what Nix builtins.fetchGit defaults to.
        # Should be refs/heads/HEAD but that errors.
        ref = "HEAD"
        rev = spec["rev"]
        ver = git_short_rev(rev)
    elseif haskey(spec, "branch")
        ref = "refs/heads/$(spec["branch"])"
        rev = git_ref2rev(url, ref)
        ver = spec["branch"] 
    elseif haskey(spec, "tag")
        ref = "refs/tags/$(spec["tag"])"
        rev = git_ref2rev(url, ref)
        ver = tryparse_version(splitpath(spec["tag"])[end])
        meta["tag"] = spec["tag"]
    elseif haskey(spec, "latest_semver_tag")
        ref, rev, tag, ver = git_latest_semver_tag(url)
        meta["tag"] = tag
    else
        nixsourcerer_error("Unknown spec: ", string(spec))
    end

    meta["ref"] = ref
    meta["rev"] = rev

    fetcher_args = Dict{Symbol,Any}(Symbol(k) => v for (k,v) in extraArgs)
    fetcher_args[:name] = sanitize_name(get(spec, "name", git_short_rev(rev)))
    fetcher_args[:url] = url 
    fetcher_args[:rev] = rev
    if builtin
        fetcher_name = "builtins.fetchGit"
        fetcher_args[:ref] = ref
        # TODO
        # Force build since nix-prefetch doesn't built builtins.fetchGit
        # build_source(fetcher_name, fetcher_args)
    else
        # TODO fetchgit doesn't have ref option
        fetcher_name = "pkgs.fetchgit"
        fetcher_args[:fetchSubmodules] = submodule
        
        hash = get_sha256(fetcher_name, fetcher_args)

        if builtin
            fetcher_args[:sha256] = string(hash, encoding=Base32Nix())
        else
            fetcher_args[:hash] = string(hash) 
        end
    end

    return Source(; pname=name, version=ver, fetcher_name, fetcher_args)
end

# TODO kind of a hack
function git_ref2rev(url::AbstractString, ref::AbstractString)
    output = strip(run_suppress(`$(git()) ls-remote $url $ref`, out=true))
    lines = split(output, '\n')
    @assert length(lines) == 1
    columns = split(lines[1], '\t')
    @assert length(columns) == 2
    rev = columns[1]

    @assert match(r"\b([a-f0-9]{40})\b", rev) !== nothing
    return rev
end
#  git -c 'versionsort.suffix=-' \
#     ls-remote --exit-code --refs --sort='version:refname' --tags "$URL" '*.*.*' \
#     | tail --lines=1 \
#     | cut --delimiter='/' --fields=3
function git_latest_semver_tag(url::AbstractString; prefix::AbstractString = "")
    args = map(
        identity,
        [
            "-c",
            "versionsort.suffix=-",
            "ls-remote",
            "--exit-code",
            "--refs",
            "--sort=version:refname",
            "--tags",
            url,
        ],
    )
    cmd = `$(git()) $args`
    lines = readlines(pipeline(cmd, stderr=stderr))
    parsed = map(lines) do l
        rev, ref = split(strip(l))
        m = match(r"^refs/tags/(.*)", ref)
        if m === nothing 
            return (rev, ref, nothing, nothing) 
        else
            tag = only(m.captures)
            return (rev, ref, tag, tryparse(VersionNumber, tag))
        end
    end
    valid = filter(parsed) do (rev, ref, tag, v)
        v !== nothing && v.build === () && v.prerelease === ()
    end
    if length(valid) > 0
        sort!(valid, by = x -> x[end])
        return valid[end]
    else
        return nothing
    end
end
# cut --delimiter='/' --fields=3
