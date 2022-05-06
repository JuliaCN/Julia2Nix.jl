# TODO add ssh/https option
# TODO offset more work into git.jl
#  - e.g. get rid of github_get_rev_sha_from_ref
#

const ARCHIVE_MIME_TYPES = (
    "application/x-xz", "application/gzip", "application/x-bzip2", "application/x-bzip", "application/zip", "application/x-7z-compressed"
)

const GITHUB_SCHEMA = SchemaSet(
    SimpleSchema("owner", String, true),
    SimpleSchema("repo", String, true),
    ExclusiveSchema(
        ("rev", "branch", "tag", "release", "latest_semver_tag"), (String, String, String, String, Bool), true
    ),
    DependentSchema("assets", Union{Bool,Vector{String}}, ("release",), (String,), false),
    SimpleSchema("submodule", Bool, false),
    SimpleSchema("extraArgs", Dict, false),
)

# TODO add test for asset handling
function github_handler(name::AbstractString, spec::AbstractDict)
    builtin = get(spec, "builtin", false)
    submodule = get(spec, "submodule", false)
    owner = spec["owner"]
    repo = spec["repo"]
    url = "https://github.com/$(owner)/$(repo).git"
    meta = Dict()
    extraArgs = get(spec, "extraArgs", Dict())

    if haskey(spec, "rev")
        rev = spec["rev"]
        ver = git_short_rev(rev)
    elseif haskey(spec, "branch")
        rev = github_get_rev_sha_from_ref(owner, repo, "heads/$(spec["branch"])")
        ver = spec["branch"]
    elseif haskey(spec, "tag")
        rev = github_get_rev_sha_from_ref(owner, repo, "tags/$(spec["tag"])")
        ver = string(tryparse_version(splitpath(spec["tag"])[end]))
    elseif haskey(spec, "latest_semver_tag")
        rev, ref, tag, ver = git_latest_semver_tag(url)
        ver = string(ver)
        meta["tag"] = tag
    elseif haskey(spec, "release")
        tag, rev, ver, assets = github_get_release(owner, repo, spec["release"], get(spec, "assets", false), builtin, extraArgs)
        meta["tag"] = tag
        meta["assets"] = assets
    else
        nixsourcerer_error("Unknown spec: ", string(spec))
    end
    meta["rev"] = rev

    source_name = sanitize_name(get(spec, "name", git_short_rev(rev)))
    if submodule
        new_spec = subset(spec, keys(DEFAULT_SCHEMA_SET)..., "submodule", "builtin")
        new_spec["name"] = source_name 
        new_spec["url"] = url
        new_spec["rev"] = rev
        new_spec["extraArgs"] = extraArgs
        source = git_handler(name, new_spec)
        source.version = ver
        return source
    else
        new_spec = subset(spec, keys(DEFAULT_SCHEMA_SET)...)
        new_spec["name"] = source_name 
        new_spec["url"] = "https://github.com/$(owner)/$(repo)/archive/$(rev).tar.gz"
        new_spec["extraArgs"] = extraArgs
        source = archive_handler(name, new_spec)
        return Source(;
            pname=name, version=ver, fetcher_name=source.fetcher_name, fetcher_args=source.fetcher_args, meta
        )
    end
end

function github_get_rev_sha_from_ref(owner, repo, ref)
    return github_api_get(owner, repo, "git/ref/$ref")["object"]["sha"]
end

function github_get_release(owner, repo, release, assets, builtin, extraArgs)
    # if builtin && get(ENV, "GITHUB_TOKEN", nothing) !== nothing
    #     nixsourcerer_error("Cannot use builtin fetcher for assets when GITHUB_TOKEN is provided")
    # end
    if builtin
        nixsourcerer_error("Cannot use builtin fetcher for GitHub assets")
    end

    rel = github_api_get(owner, repo, "releases/$release")

    tag = rel["tag_name"]
    rev = github_get_rev_sha_from_ref(owner, repo, "tags/$tag")
    ver = tryparse_version(splitpath(tag)[end])

    if assets isa Bool
        assets = assets ? map(a -> a["name"], rel["assets"]) : []
    else
        assets = collect(Iterators.flatten(
            map(assets) do asset
                m = match(r"r\"(.*)\"", asset)
                if m === nothing
                    return [asset]
                else
                    reg = Regex(only(m.captures))
                    return filter(map(a -> a["name"], rel["assets"])) do name
                        match(reg, name) !== nothing
                    end
                end
            end,
        ))
    end

    assets_dict = Dict()
    # TODO auth header? CurlOpts? --netrc-file?
    #   wget -q --auth-no-challenge --header='Accept:application/octet-stream' \
    # https://$TOKEN:@api.github.com/repos/$REPO/releases/assets/$asset_id \
    # -O $2

    fetcher_args = Dict{Symbol,Any}(:curlOpts => "-L --header Accept:application/octet-stream")
    for (k, v) in extraArgs
        fetcher_args[Symbol(k)] = v
    end
    for asset in assets
        idx = findfirst(a -> a["name"] == asset, rel["assets"])
        info = rel["assets"][idx]

        fetcher_args = copy(fetcher_args)
        fetcher_args[:url] = info["browser_download_url"]
        if info["content_type"] in ARCHIVE_MIME_TYPES 
            fetcher_name = "pkgs.fetchzip"
            hash = try
                get_sha256(fetcher_name, fetcher_args)
            catch
                fetcher_args[:stripRoot] = false
                get_sha256(fetcher_name, fetcher_args)
            end
            version = version_string(hash)
            fetcher_args[:hash] = string(hash) 
        else
            fetcher_name = "pkgs.fetchurl"
            fetcher_args[:hash] = string(get_sha256(fetcher_name, fetcher_args))
        end

        fetcher = Fetcher(fetcher_name, fetcher_args)

        assets_dict[asset] = fetcher
    end

    return tag, rev, ver, assets_dict
end

function github_api_get(owner, repo, endpoint)
    headers = Dict("Accept" => "application/vnd.github.v3+json")
    url = "https://api.github.com/repos/$(owner)/$(repo)/$endpoint"
    return github_get(url, headers)
end

function github_get(url::String, headers::Dict=Dict())
    if !haskey(headers, "Authorization") && haskey(ENV, "GITHUB_TOKEN")
        headers["Authorization"] = "token $(ENV["GITHUB_TOKEN"])"
    end
    r = HTTP.get(url, headers)
    return JSON.parse(String(r.body))
end
