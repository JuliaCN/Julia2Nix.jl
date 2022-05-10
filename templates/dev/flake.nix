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
      in rec {
        devShells.default = pkgs.devshell.mkShell {
          imports = [inputs.julia2nix.${pkgs.system}.julia2nix.devshellProfiles.packages];
        };
      })
    )
    // {
      overlays.default = final: prev: {};
    };
}
