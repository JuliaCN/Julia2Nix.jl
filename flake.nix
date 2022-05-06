{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.general-registry.url = "github:JuliaRegistries/General";
  inputs.general-registry.flake = false;

  outputs = {self, ...} @ inputs:
    (
      inputs.flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system}.appendOverlays [
          inputs.devshell.overlay
          self.overlays.default
        ];
      in rec {
        packages = {
          inherit (pkgs) julia2nix;
        };
        devShells.default = import ./nix/devshell.nix {inherit pkgs inputs;};
      })
    )
    // {
      overlays = import ./nix/overlays.nix {inherit inputs;};
    };
}
