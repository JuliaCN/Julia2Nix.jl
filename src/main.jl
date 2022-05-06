using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "paths"
        help = "Environment to update"
        required = false
        arg_type = String
        action = :store_arg
        nargs = '*'
        default = [ pwd() ]
        "-n", "--names"
        help = "Source names to update in `path`"
        required = false
        arg_type = String
        nargs = '+'
        default = nothing
        "-r", "--recursive"
        help = "Recursively update all environments under `path`"
        action = :store_true
        "-w", "--workers"
        help = "Number of worker threads to use"
        required = false
        arg_type = Int
        default = 1
        # "--ignore-script"
        # help = "Whether to skip any update.jl scripts and just update NixManifest"
        # action = :store_true
        "--no-update-julia-registries"
        help = "Whether to skip updating local Julia registries" 
        action = :store_true
        "--run-test"
        help = "Whether to run tests instead of update."
        action = :store_true
        "--dry-run"
        help = "Show what would be updated"
        action = :store_true
        "--verbose"
        help = "Enable debug output"
        action = :store_true
    end

    return parse_args(s)
end

function main()
    config = parse_commandline()
    paths = config["paths"]
    delete!(config, "paths")
    isempty(config["names"]) && delete!(config, "names")
    if get(config, "run-test", false)
        test(paths; config)
    else
        update(paths; config)
    end
    return nothing
end

function julia_main()::Cint
    try
        main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end
