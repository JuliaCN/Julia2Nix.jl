using Julia2Nix.JuNix
using ArgParse

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "system"
        help = "hardware platform and os, i.e. x86_64-linux aarch64-darwin"
        required = false
        default = ""
    end
    return parse_args(s)
end

config = parse_commandline()
function opts_gene(arch, os)
    os = os == "darwin" ? "macos" : os
    if os == "macos"
        opts = JuNix.Options(;
            nworkers = 8,
            arch = Set([arch]),
            os = Set([os]),
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
    opts
end

if config["system"] != ""
    arch, os = split(config["system"], "-")
    JuNix.main(".", "julia2nix.toml", opts_gene(arch, os))
else
    archs = ["x86_64", "aarch64"]
    oses = ["macos", "linux"]
    for arch in archs, os in oses
        JuNix.main(".", "julia2nix.toml", opts_gene(arch, os))
    end
end
nothing
