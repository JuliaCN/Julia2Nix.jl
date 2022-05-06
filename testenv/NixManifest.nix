{pkgs ? import <nixpkgs> {}}: {
  "90137ffa-7385-5640-81b9-e52037218182" = let
    fetcher = builtins.fetchTarball;
    pname = "StaticArrays-1.1.0";
    fetcherName = "builtins.fetchTarball";
    version = "1p2bvbm5brv2c0bsf7ckrsmi1yfns58s52rz61w4y9bxkr1dvnh4";
    name = "StaticArrays-1.1.0-1p2bvbm5brv2c0bsf7ckrsmi1yfns58s52rz61w4y9bxkr1dvnh4";
    outPath = fetcher fetcherArgs;
    meta = {
      "name" = "StaticArrays";
      "tree_hash" = "2f01a51c23eed210ff4a1be102c4cc8236b66e5b";
      "version" = "1.1.0";
      "path" = "packages/StaticArrays/rdb0l";
    };
    fetcherArgs = {
      "sha256" = "1p2bvbm5brv2c0bsf7ckrsmi1yfns58s52rz61w4y9bxkr1dvnh4";
      "url" = "https://pkg.julialang.org/package/90137ffa-7385-5640-81b9-e52037218182/2f01a51c23eed210ff4a1be102c4cc8236b66e5b";
    };
  in {inherit fetcher pname fetcherName version name outPath meta fetcherArgs;};
}
