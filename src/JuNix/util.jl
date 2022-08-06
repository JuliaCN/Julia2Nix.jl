# TODO move to Julia2Nix?
function get_archive_url_for_version(url::String, ref)
    if (m = match(r"https://github.com/(.*?)/(.*?).git", url)) !== nothing
        return "https://api.github.com/repos/$(m.captures[1])/$(m.captures[2])/tarball/$(ref)"
    end
    return nothing
end

function get_pkg_url(uuid::UUID, tree_hash::String)
    if (server = pkg_server()) !== nothing
        return "$server/package/$(uuid)/$(tree_hash)"
    end
end

function get_source_path(ctx::Context, name::String, uuid::UUID, tree_hash::SHA1)
    spec = Pkg.Types.PackageSpec(; name, uuid, tree_hash)
    # if VERSION <= v"1.7.0-"
    # Pkg.Operations.source_path(ctx, pkg)
    path = Pkg.Operations.source_path(ctx.env.project_file, spec)
    for depot in DEPOT_PATH
        if startswith(normpath(path), normpath(depot))
            return depot, relpath(normpath(path), normpath(depot))
        end
    end
    return nothing
end

function convert_sha256(data::String, base::Symbol)
    flag = if base === :base16
        "--to-base16"
    elseif base === :base32
        "--to-base32"
    else
        error("Unknown base $base")
    end
    return strip(run_suppress(`nix-hash --type sha256 $flag $data`, out = true))
end

function fetch_sha256(fetcher::Fetcher, opts::Options)
    parsed = parse_fetcher(fetcher, opts)
    expr = """
               { nixpkgs ? <nixpkgs> }:
               let pkgs = import nixpkgs { };
               in with pkgs; $(fetcher.name)
           """
    cmd = `nix-prefetch $expr $(parsed)`
    @debug cmd
    return strip(run_suppress(cmd; out = true))
end

function parse_fetcher(fetcher::Fetcher, opts::Options = Options())
    args = copy(fetcher.args)
    parsed = ["--hash-algo", "sha256", "--output", "raw"]

    # Hackity hack hack
    if fetcher.name == BUILTINS_GIT_FETCHER
        push!(parsed, "--no-compute-hash")
        if haskey(args, "sha256")
            delete!(args, "sha256")
        end
    end

    # Verify the sha256 we already have
    if haskey(args, "sha256")
        push!(parsed, "--no-compute-hash")
        args["hash"] = args["sha256"]
        delete!(args, "sha256")
        if opts.check_store
            push!(parsed, "--check-store")
        end
    end

    for (k, v) in args
        # Boolean flags
        if v === true
            k = "--$(k)"
            v = nothing
        elseif v === false
            k = "--no-$(k)"
            v = nothing
        else
            k = "--$(k)"
        end

        push!(parsed, string(k))
        if v !== nothing
            push!(parsed, string(v))
        end
    end

    return parsed
end

function get_os_from_opts(opts::Options)
    archs = ["x86_64", "aarch64"]
    oses = ["macos", "linux"]
    for arch in archs, os in oses
        if arch in opts.arch && os in opts.os
            return arch, if os == "macos" "darwin" else os end
        end
    end
end

function is_git_repo(path::String)
    try
        GitRepo(path)
        return true
    catch
        return false
    end
end

function get_repo_meta(path::String)
    repo = GitRepo(path)

    branch_ref = LibGit2.head(repo)
    ref = LibGit2.name(branch_ref)
    shortref = LibGit2.shortname(branch_ref)
    rev = string(LibGit2.head_oid(repo))

    remote_names = LibGit2.remotes(repo)
    remote_urls = map(remote_names) do name
        LibGit2.url(LibGit2.get(LibGit2.GitRemote, repo, name))
    end

    return (; ref, shortref, rev, remote_names, remote_urls)
end

# function isvalid_url(url::String)
#     try
#         HTTP.head(url, status_exception = true)
#         return true
#     catch
#         return false
#     end
# end

# joinpath(splitpath(path)...) removes trailing slashes
# in system independent manner
# function cleanpath(path::String) 
#     path = joinpath(splitpath(normpath(path))...)
#     @assert !endswith(path, Base.Filesystem.pathsep())
#     return path
# end
