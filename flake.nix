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
        devShells = import ./nix/devshell {inherit pkgs inputs;};
      })
    )
    // {
      overlays = import ./nix/overlays.nix {inherit inputs;};

      packages.x86_64-linux = (system: {
        inherit
          (self.pkgs.${system})
          julia_17-bin
          julia_16-bin
          ;
        julia_18-beta-bin = self.pkgs.${system}.julia-bin {
          inherit system;
          version = "18-beta";
        };
      }) "x86_64-linux";

      packages.aarch64-linux = (system: {
        julia_18-beta-bin = self.pkgs.${system}.julia-bin {
          inherit system;
          version = "18-beta";
        };
      }) "aarch64-linux";

      packages.aarch64-darwin = (system: {
        julia_18-beta-bin = self.pkgs.${system}.lib.installApp {
          inherit system;
          version = "18-beta";
        };
      }) "aarch64-darwin";

      packages.x86_64-darwin = (system: {
        julia_18-beta-bin = self.pkgs.x86_64-darwin.lib.installApp {
          inherit system;
          version = "18-beta";
        };
        julia_17-bin = self.pkgs.x86_64-darwin.lib.installApp {
          inherit system;
          version = "17-release";
        };
      }) "x86_64-darwin";
    };
}
