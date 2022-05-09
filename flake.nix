{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.general-registry.url = "github:JuliaRegistries/General";
  inputs.general-registry.flake = false;

  outputs = {self, ...} @ inputs:
    (
      inputs.flake-utils.lib.eachDefaultSystem (system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system}.appendOverlays [
          inputs.devshell.overlay
          self.overlays.default
        ];
      in rec {
        inherit pkgs;
        lib = {
          inherit
            (pkgs)
            julia2nix
            ;
        };
        packages = {
          example = lib.julia2nix {
            src = ./.;
            packages = ./testenv/Depot.nix;
          };
        };
        devShells.default = import ./nix/devshell.nix {inherit pkgs inputs;};
      })
    )
    // {
      overlays = import ./nix/overlays.nix {inherit inputs;};

      packages.x86_64-linux = {
        inherit
          (self.pkgs.x86_64-linux)
          julia_17-bin
          julia_16-bin
          ;
        julia_18-beta-bin = self.pkgs.x86_64-linux.julia_18-beta-bin "x86_64-linux";
      };

      packages.aarch64-linux = {
        julia_18-beta-bin = self.pkgs.x86_64-linux.julia_18-beta-bin "aarch64-linux";
      };

      packages.aarch64-darwin = {
        julia_18-beta-bin = self.pkgs.aarch64-darwin.lib.installApp {
          inherit (self.pkgs.aarch64-darwin.julia-sources.julia-18-beta-macaarch64) pname version src;
        };
      };
      packages.x86_64-darwin = {
        julia_18-beta-bin = self.pkgs.x86_64-darwin.lib.installApp {
          inherit (self.pkgs.x86_64-darwin.julia-sources.julia-18-beta-macaarch64) pname version src;
        };
      };
    };
}
