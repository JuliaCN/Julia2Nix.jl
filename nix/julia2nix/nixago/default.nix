{
  inputs,
  cell,
}: let
  inherit (inputs) std-data-collection;
  juliaFormatter = cell.lib.buildEnv {
    src = inputs.nix-filter.lib.filter {
      root = ./.;
      include = [
        ./julia2nix.toml
        ./Project.toml
        ./Manifest.toml
      ];
    };
    name = "juliaFormatter";
    package = cell.lib.julia-wrapped {};
  };
in {
  inherit juliaFormatter;

  treefmt = std-data-collection.data.configs.treefmt {
    data.formatter.prettier = {
      excludes = ["Manifest.toml" "Project.toml" "generated.json" "julia2nix.toml"];
    };
    data.formatter.nix = {
      excludes = ["generated.nix"];
    };
    # configData.formatter.julia = {
    #   command = "${juliaFormatter}/bin/julia";
    #   options = ["${./format.jl}"];
    #   includes = ["*.jl"];
    # };
  };
}
