module TestCrate

include("preamble.jl")

@testset "crate" begin
    pname = "lscolors"
    version = Julia2Nix.parse_crate_version("lscolors", "stable")
    url = "https://crates.io/api/v1/crates/$(pname)/$(version)/download#crate.tar.gz"
    hash = with_unpack(nix_dir_sha256, download(url); strip = true)
    name = sanitize_name("$(pname)-$(version)")

    toml = Dict(
        "test1" => Dict(
            "type" => "crate",
            "pname" => pname,
            "version" => version,
            "builtin" => true,
        ),
        "test2" => Dict("type" => "crate", "pname" => pname, "version" => version),
        "test3" => Dict("type" => "crate", "pname" => pname, "version" => "latest"),
    )
    truth = Dict(
        "test1.fetcherName" => "builtins.fetchTarball",
        "test1.fetcherArgs.url" => url,
        "test1.fetcherArgs.sha256" => string(hash, encoding = Base32Nix()),
        "test1.fetcherArgs.name" => name,
        "test2.fetcherName" => "pkgs.fetchzip",
        "test2.fetcherArgs.url" => url,
        "test2.fetcherArgs.hash" => string(hash),
        "test2.fetcherArgs.name" => name,
        "test3.fetcherName" => "pkgs.fetchzip",
        "test3.fetcherArgs.url" => url,
        "test3.fetcherArgs.hash" => string(hash),
        "test3.fetcherArgs.name" => name,
    )
    runtest(toml, truth)
end

end
