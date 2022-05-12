
using Julia2Nix.JuNix

opts = JuNix.Options(;
    nworkers = 8,
    arch = Set(["x86_64"]),
    os = Set(["linux"]),
    libc = Set(["glibc"]),
    force_overwrite = true,
    check_store=true,
)
x = JuNix.main(joinpath(@__DIR__, "."), opts)
nothing
