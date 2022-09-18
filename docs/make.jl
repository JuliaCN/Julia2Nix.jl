using Documenter

makedocs(sitename = "Julia2Nix.jl")

deploydocs(
    repo = "github.com/JuliaCN/Julia2Nix.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    branch = "gh-pages",
)
