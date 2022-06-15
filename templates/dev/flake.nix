{
  description = "Julia2Nix development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    julia2nix.url = "github:JuliaCN/Julia2Nix.jl";
  };

  outputs = inputs @ {self, ...}:
    (
      inputs.flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system}.appendOverlays [
          inputs.devshell.overlay
          self.overlays.default
        ];
        julia-wrapped = inputs.julia2nix.lib.${system}.julia-wrapped {
          # package = pkgs.julia_17-bin;
          # package = julia2nix.packages.${system}.julia_18-bin;
          enable = {
            GR = true;
            python =
              pkgs.python3.buildEnv.override
              {
                extraLibs = with pkgs.python3Packages; [xlrd matplotlib pyqt5];
                ignoreCollisions = true;
              };
          };
        };

        # run this command in your project: nix run github:JuliaCN/Julia2Nix.jl#packages.x86_64-linux.julia2nix
        # we need to generate the Depot.nix first
        project = inputs.julia2nix.lib.${system}.buildProject {
          src = ./.;
          name = "your julia project";
          package = julia-wrapped;
        };
      in {
        packages = {
          default = project;
        };
        devShells.default = pkgs.devshell.mkShell {
          # imports = [inputs.julia2nix.${pkgs.system}.julia2nix.devshellProfiles.packages];
          commands = [{package = julia-wrapped;}];
        };
      })
    )
    // {
      overlays.default = final: prev: {};
    };
}
