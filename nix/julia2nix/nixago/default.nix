{
  inputs,
  cell,
}: let
  inherit (inputs) std;
  juliaFormatter = cell.library.buildEnv {
    src = inputs.nix-filter.lib.filter {
      root = ./.;
      include = [
        ./julia2nix.toml
        ./Project.toml
        ./Manifest.toml
      ];
    };
    name = "juliaFormatter";
    package = cell.library.julia-wrapped {};
  };
in {
  inherit juliaFormatter;

  treefmt = std.std.nixago.treefmt {
    configData.formatter.prettier = {
      excludes = ["Manifest.toml" "Project.toml" "generated.json" "julia2nix.toml"];
    };
    configData.formatter.nix = {
      excludes = ["generated.nix"];
    };
    # configData.formatter.julia = {
    #   command = "${juliaFormatter}/bin/julia";
    #   options = ["${./format.jl}"];
    #   includes = ["*.jl"];
    # };
  };
}
