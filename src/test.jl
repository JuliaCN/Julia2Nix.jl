macro genmodule()
    mod = gensym()
    quote
        @eval module $mod end
    end
end

function test(parent::AbstractString=pwd(); config::AbstractDict=Dict())
    isdir(parent) || nixsourcerer_error("Not a directory: $(parent)")

    if get(config, "verbose", false)
        ENV["JULIA_DEBUG"] = string(@__MODULE__)
    end

    paths = String[]
    has_test(parent) && push!(paths, parent) 
    if get(config, "recursive", false)
        for (root, dirs, files) in walkdir(path)
            for dir in dirs
                path = joinpath(root, dir)
                has_test(path) && push!(paths, path) 
            end
        end
    end

    @testset "$parent" begin
        @testset "$(relpath(path, parent))" for path in paths
            @info path
            cd(path) do
                mod = @genmodule
                Base.include(mod, joinpath(path, "runtests.jl"))
            end
        end
    end
end

has_test(path) = isfile(joinpath(path, "runtests.jl"))
