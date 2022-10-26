{
  inputs,
  cell,
}: let
  inherit (inputs.cells-lab._writers.lib) writeShellApplication;
  inherit (inputs) nixpkgs;
in {
  mkdoc = let
    juliaDoc = cell.lib.buildEnv {
      name = "julia-doc";
      src = ./doc;
      package = cell.lib.julia-wrapped {
        package = cell.packages.julia_18-bin;
      };
    };
  in
    writeShellApplication {
      name = "mkdoc";
      runtimeInputs = [
        # juliaDoc
        nixpkgs.julia_18-bin
      ];
      text = ''
        julia --project="$*" -e 'using Pkg; Pkg.develop(PackageSpec(; path=pwd())); Pkg.instantiate();'
        julia --project="$*" "$*"/make.jl deploy
        # find "$*" -type l -exec bash ${./fix-symlink.sh} {} +
      '';
    };

  julia-ion = cell.lib.buildEnv {
      name = "julia-ion";
      src = ./ion;
      extraBuildInputs = [
        nixpkgs.libsodium
      ];
      package = cell.lib.julia-wrapped {
        package = cell.packages.julia_18-bin;
      };
    };

  ion = let
    julia-ion = cell.lib.buildEnv {
      name = "julia-ion";
      src = ./ion;
      package = cell.lib.julia-wrapped {
        package = cell.packages.julia_18-bin;
      };
    };
  in
    writeShellApplication {
      name = "julia-ion";
      runtimeInputs = [
        julia-ion
      ];
      text = ''
      '';
    };
}
