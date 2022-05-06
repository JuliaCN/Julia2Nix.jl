function select_registry_fetchers(opts::Options)
    tofetch = Dict{RegistryInfo,Vector{Fetcher}}()
    pkg_server_urls = Pkg.Types.pkg_server_registry_urls()
    for reg in collect_registries()
        fetchers = tofetch[reg] = Fetcher[]
        name = "registry-$(reg.name)"
        if haskey(pkg_server_urls, reg.uuid)
            url = "$(pkg_server_urls[reg.uuid])#registry.tar.gz"
            push!(
                fetchers, Fetcher(ARCHIVE_FETCHER, Dict("name" => name, "url" => url, "stripRoot" => false))
            )
        end
        if is_git_repo(reg.path)
            repo_meta = get_repo_meta(reg.path)
            if isempty(repo_meta.remote_urls)
                @warn "No remotes found for registry $(reg.path). Skipping."
                continue
            else
                if length(repo_meta.remote_urls) > 1
                    remote_url = first(repo_meta.remote_urls)
                    @warn "Multiple remotes found for $(reg.path). Using $remote_url"
                else
                    remote_url = only(repo_meta.remote_urls)
                end
                fetcher = Fetcher(
                    GIT_FETCHER, Dict("name" => name, "url" => remote_url, "rev" => repo_meta.rev)
                )
                push!(fetchers, fetcher)
            end
        end
    end

    selected = select_fetchers(tofetch, opts)
    for (reg, fetcher) in selected
        fetcher === nothing && error("Registry with UUID $(reg.uuid) has no sources")
    end

    return selected
end

function select_pkg_fetchers(pkgs::Vector{PackageInfo}, opts::Options)
    tofetch = Dict{PackageInfo,Vector{Fetcher}}()
    for pkg in pkgs
        fetchers = tofetch[pkg] = Fetcher[]
        name = "package-$(pkg.name)"
        if opts.pkg_server !== nothing
            url = "$(opts.pkg_server)/package/$(pkg.uuid)/$(pkg.tree_hash)#package.tar.gz"
            push!(
                fetchers,
                Fetcher(
                    ARCHIVE_FETCHER,
                    Dict("name" => name, "url" => url, "stripRoot" => false, "name" => name), 
                ),
            )
        end
        for url in pkg.archives
            push!(fetchers, Fetcher(ARCHIVE_FETCHER, Dict("name" => name, "url" => pkg.url)))
        end
        for repo in pkg.repos
            push!(
                fetchers, Fetcher(GIT_FETCHER, Dict("name" => name, "url" => repo, "rev" => pkg.tree_hash))
            )
        end
    end

    selected = select_fetchers(tofetch, opts)
    for (pkg, fetcher) in selected
        fetcher === nothing && error("Package with UUID '$(pkg.uuid)' has no sources")
    end

    return selected
end

function select_artifact_fetchers(pkgs::Vector{PackageInfo}, opts::Options)
    tofetch = Dict{ArtifactInfo,Vector{Fetcher}}()
    for pkg in pkgs, (artifact_name, artifacts) in pkg.artifacts, artifact in artifacts
        if !is_artifact_required(artifact, opts) || haskey(tofetch, artifact)
            # Either we don't need to download it, or we've already seen it
            continue
        end

        fetchers = tofetch[artifact] = Fetcher[]
        name = "artifact-$(artifact.tree_hash)"
        if opts.pkg_server !== nothing
            # Prefer using Pkg server even though we don't have a sha256
            url = "$(opts.pkg_server)/artifact/$(artifact.tree_hash)#artifact.tar.gz"
            push!(
                fetchers, Fetcher(ARCHIVE_FETCHER, Dict("name" => name, "url" => url, "stripRoot" => false))
            )
        elseif isempty(artifact.downloads)
            @warn "Artifact $artifact_name ($(artifact.tree_hash)) has no downloads"
            continue
        else
            for dl in artifact.downloads
                push!(
                    fetchers,
                    Fetcher(ARCHIVE_FETCHER, Dict("name" => name, "url" => dl.url, "sha256" => dl.sha256)),
                )
            end
        end
    end

    selected = select_fetchers(tofetch, opts)
    for (artifact, fetcher) in selected
        fetcher === nothing && error("Artifact $(artifact.name) has no sources")
    end

    return selected
end

function is_artifact_required(artifact::ArtifactInfo, opts::Options)
    lazy_matches = !(artifact.lazy && !opts.lazy_artifacts)
    system_matches = (
        (opts.arch === nothing || artifact.arch in opts.arch) &&
        (opts.os === nothing || artifact.os in opts.os) &&
        (opts.libc === nothing || artifact.libc in opts.libc)
    )
    return lazy_matches && system_matches
end

function select_fetchers(tofetch::Dict{K,Vector{Fetcher}}, opts::Options) where {K}
    jobs = Channel{Tuple{K,Vector{Fetcher}}}(opts.nworkers)
    results = Channel{Tuple{K,FetcherResult}}(opts.nworkers)
    @sync begin
        # writer
        @async begin
            for (key, fetchers) in tofetch
                put!(jobs, (key, fetchers))
            end
        end

        # readers
        for i in 1:(opts.nworkers)
            @async begin
                for (key, fetchers) in jobs
                    fetcher = select_fetcher(fetchers, opts)
                    put!(results, (key, fetcher))
                end
            end
        end

        bar = MiniProgressBar(;
            indent=2,
            header="Progress",
            color=Base.info_color(),
            percentage=false,
            always_reprint=true,
            max=length(tofetch),
        )
        try
            start_progress(stdout, bar)
            selected = Dict{K,FetcherResult}()
            for i in 1:length(tofetch)
                bar.current = i

                key, fetcher = take!(results)
                selected[key] = fetcher

                # print_progress_bottom(stdout)
                show_progress(stdout, bar)
            end
            return selected
        finally
            end_progress(stdout, bar)
            close(jobs)
            close(results)
        end
    end
end

function select_fetcher(fetchers::Vector{Fetcher}, opts::Options)
    for fetcher in fetchers
        try
            sha256 = fetch_sha256(fetcher, opts)
            if fetcher.name != BUILTINS_GIT_FETCHER
                fetcher.args["sha256"] = sha256
            end
            return fetcher
        catch e
            bt = backtrace()
            @error "Fetcher failed: $fetcher\n$(sprint(showerror, e, bt))"
            rethrow(e)
            continue
        end
    end
    return nothing
end
