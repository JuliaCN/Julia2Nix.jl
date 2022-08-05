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
system = split(config["system"], "-")
arch = system[1]
if system == "darwin"
    os = "macos"
else
    os = system[2]
end
return nothing

opts = JuNix.Options(;
    nworkers = 8,
    arch = Set([arch]),
    os = Set([os]),
    libc = Set(["glibc"]),
    force_overwrite = true,
    check_store = true
)
x = JuNix.main(".", "julia2nix.toml", opts)
nothing
