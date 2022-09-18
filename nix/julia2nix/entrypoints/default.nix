{
  inputs,
  cell,
}: let
  inherit (inputs.cells-lab._writers.library) writeShellApplication;
  inherit (inputs) self nixpkgs std;
in {
  mkdoc = let
    juliaDoc = cell.library.buildEnv {
    src = inputs.nix-filter.lib.filter {
      root = ./doc;
      include = [
        ./julia2nix.toml
        ./Project.toml
        ./Manifest.toml
      ];
    };
    name = "juliaDoc";
    package = cell.library.julia-wrapped {};
  };
  in
    writeShellApplication {
      name = "mkdoc";
      runtimeInputs = [juliaDoc];
      text = ''
      julia
      '';
    };
}
