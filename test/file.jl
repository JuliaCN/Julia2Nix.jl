module TestFile

include("preamble.jl")

@testset "file" begin
    url = "https://julialang-s3.julialang.org/bin/versions.json"
    hash = nix_file_sha256(download(url))
    name = url_name(url)
    toml = Dict(
        "test1" => Dict("type" => "file", "url" => url, "builtin" => false),
        "test2" => Dict("type" => "file", "url" => url, "builtin" => true),
    )
    truth = Dict(
        "test1.fetcherName" => "pkgs.fetchurl",
        "test1.fetcherArgs.url" => url,
        "test1.fetcherArgs.hash " => string(hash),
        "test1.fetcherArgs.name" => name,

        "test2.fetcherName" => "builtins.fetchurl",
        "test2.fetcherArgs.url" => url,
        "test2.fetcherArgs.sha256" => string(hash, encoding=Base32Nix()),
        "test2.fetcherArgs.name" => name,
    )
    runtest(toml, truth)
end

end
