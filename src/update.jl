update(path::AbstractString, args...; kwargs...) = update([ path ], args...; kwargs...)

function update(paths::Vector{<:AbstractString}=[pwd()]; config::AbstractDict=default_config(), io=stdout)
    config = parse_config(config)
    setup(config)

    if config["verbose"]
        ENV["JULIA_DEBUG"] = string(@__MODULE__)
    end

    allpaths = String[]
    if config["recursive"]
        for path in paths
            if isdir(path)
                for (root, dirs, files) in walkdir(path; topdown=false)
                    for dir in dirs
                        subpath = joinpath(root, dir)
                        should_update(subpath) && push!(allpaths, subpath)
                    end
                end
            end
            should_update(path) && push!(allpaths, path)
        end
    else
        append!(allpaths, paths)
    end

    # TODO makes debugging failures difficult
    # Try to catch dependencies between updates
    # shuffle!(allpaths)

    print_path = function (path)
        path = cleanpath(path)
        s = !config["ignore-script"] && has_update_script(path)
        j = !s && has_julia_project(path)
        f = !j && !s && has_flake(path)
        n = !j && !s && has_project(path)
        s, j, f, n = map(x -> x ? "+" : "-", (s, j, f, n))
        str = @sprintf "%-4sS%-3sJ%-3sF%-3sN%-3s%-10s" "" s j f n ""
        printstyled(io, str; color=:magenta)
        return println(path == "." ? ". (cwd)" : path)
    end

    printstyledln(io, "Updating the following paths:"; color=:blue, bold=true)
    printstyledln(io, "S = Update (S)cript | "; color=:blue, bold=true)
    printstyledln(io, "J = (J)ulia Project | "; color=:blue, bold=true)
    printstyledln(io, "F = (F)lake | "; color=:blue, bold=true)
    printstyledln(io, "N = (N)ix Project"; color=:blue, bold=true)

    println()
    foreach(print_path, allpaths)
    println()

    jobs = []
    for path in allpaths
        append!(jobs, _update(path; config, io))
    end

    # Since we're updating N paths with M packages each try not to use N*M workers
    # workers = min(length(allpaths), config["workers"])
    # workers = config["workers"] = round(Int, sqrt(workers), RoundUp)
    run_jobs(jobs, workers=config["workers"])

    println()
    printstyledln(io, "Done! Congrats on updating $(length(allpaths)) package(s):"; color=:blue, bold=true)

    return nothing
end

function setup(config)
    # We don't want overlays or anything else as it breaks nix-prefetch
    # TODO don't use <nixpkgs>?>
    nixpkgs = strip(run_suppress(`nix eval --impure --expr '<nixpkgs>'`; out=true))
    isdir(nixpkgs) || nixsourcerer_error("Could not locate <nixpkgs> in NIX_PATH")
    ENV["NIX_PATH"] = "nixpkgs=$(nixpkgs)"

    ENV["NIX_SOURCERER_WORKERS"] = config["workers"] 

    # We only want to update the registry once per session
    if !config["no-update-julia-registries"]
        run_suppress(`julia --startup-file=no --history-file=no -e 'using Pkg; Pkg.Registry.update()'`)
        # Pkg.Registry.update()
    end

    return nothing
end

function _update(path; config, io)
    jobs = []
    push!(jobs, () -> printstyledln(io, "Updating $(cleanpath(path))"; color=:yellow, bold=true))
    io = IOContext(io, :indent => get(io, :indent, 0) + PAD_WIDTH)
    if has_update_script(path)
        push!(jobs, _run_update_script(path; config, io))
    else
        has_julia_project(path) && push!(jobs, _update_julia_project(path; config, io))
        has_flake(path)  && push!(jobs, _update_flake(path; config, io))
        has_project(path) && append!(jobs, _update_package(path; config, io))
    end
    # TODO gets printed early because async
    # push!(jobs, () -> printstyledln(io, "Finished updating $(cleanpath(path))"; color=:yellow, bold=true))
    return jobs 
end

run_update_script(path::String; config=default_config(), io=stdout) = _run_update_script(path; config, io)()
function _run_update_script(path::String; config, io)
    config = parse_config(config)
    () -> begin
        indented_printstyledln(
            io,
            "Updating using script at $(cleanpath(get_update_script(path))). Skipped NixManifest.toml/$(FLAKE_FILENAME)/Manifest.toml.";
            color=:green,
            bold=true,
        )
        if !config["dry-run"]
            path = get_update_script(path)
            shell_file = joinpath(dirname(path), "shell.nix")
            flake_file = joinpath(dirname(path), "flake.nix")

            preamble = """
                    using Pkg
                    Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
                    Pkg.instantiate(update_registry=false)
                    include("$path")
                    """
            jlcmd = [
                "julia",
                "-e",
            ]

            args = [ "--option max-jobs 1", "--option cores 0" ]
            !config["verbose"] && push!(args, "--quiet")
            if isfile(shell_file)
                push!(jlcmd, "'$preamble'")
                cmd = `nix-shell $shell_file --run "$(join(jlcmd, ' '))"`
            elseif isfile(flake_file)
                push!(jlcmd, "'$preamble'")
                cmd = `nix develop $(dirname(flake_file)) -c julia -e $preamble`
            else
                push!(jlcmd, "$preamble")
                cmd = `$jlcmd`
            end
            env = copy(ENV)
            env["JULIA_PROJECT"] = dirname(path)
            # TODO run_suppress?
            run(setenv(cmd, env, dir=dirname(path)))
        end

        return nothing
    end
end

update_flake(path; config=default_config(), io=stdout) = _update_flake(path; config, io)()
function _update_flake(path; config, io)
    config = parse_config(config)
    () -> begin 
        path = dirname(get_flake(path))
        indented_printstyledln(io, "Updating flake at $(cleanpath(get_flake(path)))"; color=:green, bold=true)
        if !config["dry-run"]
            run_suppress(`nix flake update $path`)
        end
        return nothing
    end
end

update_julia_project(path; config=default_config(), io=stdout) = _update_julia_project(path; config, io)()
function _update_julia_project(path; config, io)
    config = parse_config(config)
    () -> begin
        path = get_julia_project(path)
        indented_printstyledln(io, "Updating Julia project at $(cleanpath(get_julia_project(path)))"; color=:green, bold=true)
        if !config["dry-run"]
            run_suppress(`julia --project=$path --startup-file=no --history-file=no -e 'using Pkg; Pkg.update()'`)
        end
        return nothing
    end
end

function update_package(path::AbstractString=pwd(); config=default_config(), io=stdout) 
    config = parse_config(config)
    jobs = _update_package(path; config, io)
    run_jobs(jobs, workers=config["workers"])
    return nothing
end

function _update_package(path; config, io) 
    config = parse_config(config)
    if config["verbose"]
        ENV["JULIA_DEBUG"] = string(@__MODULE__)
    end

    package = read_package(path)
    validate(package)

    if haskey(config, "names")
        names = config["names"]
        for name in config["names"]
            if !haskey(package.project.specs, name)
                nixsourcerer_error("Key $name missing from $(package.project_file)")
            end
        end
    else
        names = keys(package.project.specs)
    end

    jobs = []
    l = ReentrantLock()
    push!(jobs, () -> indented_printstyledln(io, "Updating NixManifest.toml at $(cleanpath(get_project(path)))"; color=:green, bold=true))
    for name in names
        push!(jobs, () -> begin
            lock(l) do
                update!(package, name; config, io=IOContext(io, :indent => get(io, :indent, 0) + PAD_WIDTH))
                write_package(package)
            end
            return nothing
        end)
    end

    return jobs
end

function update!(package::Package, name::AbstractString; config=default_config(), io=stdout)
    config = parse_config(config)
    path = cleanpath(dirname(package.project_file))
    try
        if !config["dry-run"]
            project_spec = package.project.specs[name]
            manifest_source = HANDLERS[project_spec["type"]](name, project_spec)
            merge_recursively!(manifest_source.meta, get(project_spec, "meta", Dict()))
            package.manifest.sources[name] = manifest_source
        end
        indented_printstyledln(io, "Updated package $name from $path"; color=:green)
    catch e
        nixsourcerer_error("Could not update source $name from $path")
        rethrow()
    end
    return package
end

should_update(path) = has_update_script(path) || has_project(path) || has_flake(path) || has_julia_project(path)

has_file(file_or_dir, filename) = isfile(get_file(file_or_dir, filename))
function get_file(file_or_dir, filename)
    file = isfile(file_or_dir) && basename(file_or_dir) == filename ? file_or_dir : joinpath(file_or_dir, filename)
    return abspath(file)
end

get_update_script(path) = get_file(path, UPDATE_SCRIPT_FILENAME)
has_update_script(path) = has_file(path, UPDATE_SCRIPT_FILENAME)

get_flake(path) = get_file(path, FLAKE_FILENAME)
has_flake(path) = has_file(path, FLAKE_FILENAME)

get_julia_project(path) = get_file(path, JULIA_PROJECT_FILENAME)
has_julia_project(path) = has_file(path, JULIA_PROJECT_FILENAME)

get_project(path) = get_file(path, PROJECT_FILENAME)
has_project(path) = has_file(path, PROJECT_FILENAME)

get_manifest(path) =
    get_file(isfile(path) && basename(path) == PROJECT_FILENAME ? dirname(path) : path, MANIFEST_FILENAME)
has_manifest(path) =
    has_file(isfile(path) && basename(path) == PROJECT_FILENAME ? dirname(path) : path, MANIFEST_FILENAME)

