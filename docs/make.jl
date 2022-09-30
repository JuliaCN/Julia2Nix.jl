using Documenter, Julia2Nix

makedocs(sitename = "Julia2Nix.jl", modules = [Julia2Nix])

deploydocs(
    repo = "github.com/JuliaCN/Julia2Nix.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    branch = "gh-pages",
)
