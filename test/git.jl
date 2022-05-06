module TestGit

include("preamble.jl")

@testset "git" begin
    url = "https://github.com/nmattia/niv.git"
    rev = "62fcf7d0859628f1834d84a7a0706ace0223c27e"
    tag = "v0.2.19"
    hash = with_clone_and_checkout(nix_dir_sha256, url, rev)

    toml = Dict(
        "test1" => Dict("type" => "git", "url" => url, "rev" => rev),
        "test2" => Dict("type" => "git", "url" => url, "rev" => rev, "builtin" => true),
        "test3" => Dict("type" => "git", "url" => url, "rev" => rev, "submodule" => true),
        "test4" => Dict("type" => "git", "url" => url, "tag" => tag),
    )
    truth = Dict(
        "test1.fetcherName" => "pkgs.fetchgit",
        "test1.fetcherArgs.url" => url,
        "test1.fetcherArgs.rev" => rev,
        "test1.fetcherArgs.hash" => string(hash),
        "test1.fetcherArgs.name" => git_short_rev(rev),

        "test2.fetcherName" => "builtins.fetchGit",
        "test2.fetcherArgs.url" => url,
        "test2.fetcherArgs.rev" => rev,
        # NOTE: builtin doesn't have a sha256
        # "test2.fetcherArgs.name" => git_short_rev(rev),

        "test3.fetcherName" => "pkgs.fetchgit",
        "test3.fetcherArgs.url" => url,
        "test3.fetcherArgs.rev" => rev,
        "test3.fetcherArgs.hash" => string(hash),
        "test3.fetcherArgs.name" => git_short_rev(rev),

        "test4.fetcherName" => "pkgs.fetchgit",
        "test4.fetcherArgs.url" => url,
        "test4.fetcherArgs.rev" => rev,
        "test4.fetcherArgs.hash" => string(hash),
        "test4.fetcherArgs.name" => git_short_rev(rev) 
    )
    runtest(toml, truth)
end

end
