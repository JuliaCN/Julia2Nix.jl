using Julia2Nix.JuNix
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "system"
        help = "hardware platform and os, i.e. x86_64-linux aarch64-darwin"
        required = true
        default = "x86_64-linux"
    end

    return parse_args(s)
end

config = parse_commandline()
arch, os = split(config["system"], "-")

if os == "darwin"
    opts = JuNix.Options(;
        nworkers = 8,
        arch = Set([arch]),
        os = Set(["macos"]),
        check_store = true,
    )
else
    opts = JuNix.Options(;
        nworkers = 8,
        arch = Set([arch]),
        os = Set([os]),
        libc = Set(["glibc"]),
        check_store = true,
    )
end
return nothing

x = JuNix.main(".", "julia2nix.toml", opts)
nothing
