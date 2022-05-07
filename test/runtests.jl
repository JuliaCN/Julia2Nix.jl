include("preamble.jl")

@testset "julia2nix.jl" begin
    include("file.jl")
    include("archive.jl")
    include("crate.jl")
    # include("git.jl") failed by missing path?
    # include("github.jl")
end
