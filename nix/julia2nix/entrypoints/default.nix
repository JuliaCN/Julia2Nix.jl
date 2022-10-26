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

  ion = let
    julia-ion =
      (cell.lib.buildEnv {
        name = "julia-ion";
        src = ./ion;
        extraDepot = {
          extraJulia2nix = {
            fetchzip.artifact-1fce04a1a7eedfdf2b0b81ca9001494525764e11 = {
              name = "artifacts/1fce04a1a7eedfdf2b0b81ca9001494525764e11";
              sha256 = "sha256-YlrXTPJLJGjHLjoVkuygwtTV6kFUIO2VHZXwf3COIt0=";
              stripRoot = false;
              url = "https://pkg.julialang.org/artifact/1fce04a1a7eedfdf2b0b81ca9001494525764e11#artifact.tar.gz";
            };
          };
        };
        package = cell.lib.julia-wrapped {
          package = cell.packages.julia_18-bin;
        };
      })
      .overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [nixpkgs.rsync];
        postInstall = ''

          $out/bin/julia -e 'using Ion; Ion.comonicon_install()';
          # make sure we can write the ./julia/bin/* in our $out/store
          rsync -avzhr $HOME/.julia/ $out
        '';
      });
  in
    writeShellApplication {
      name = "julia-ion";
      runtimeInputs = [
        julia-ion
      ];
      text = ''
        ion --help
      '';
    };
}
