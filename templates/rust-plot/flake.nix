{
  description = "Rust development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    nix-filter.url = "github:/numtide/nix-filter";
    nix-filter.inputs.nixpkgs.follows = "nixpkgs";

    cheatsheet.url = "github:GTrunSec/cheatsheet";
    cheatsheet.inputs.nixpkgs.follows = "nixpkgs";
    julia2nix.url = "github:JuliaCN/julia2nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    (
      flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] (system: let
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
          self.overlays.default
          inputs.rust-overlay.overlay
          inputs.devshell.overlay
        ];

        craneLib = (inputs.crane.mkLib pkgs).overrideScope' (final: prev: {
          rustc = pkgs.rust-final;
          cargo = pkgs.rust-final;
          rustfmt = pkgs.rust-final;
        });
        julia-wrapped = inputs.julia2nix.lib.${system}.julia-wrapped {
          julia = inputs.julia2nix.packages.${system}.julia_17-bin;
          pythonEnv =
            pkgs.python3.buildEnv.override
            {
              extraLibs = with pkgs.python3Packages; [matplotlib pyqt5];
              ignoreCollisions = true;
            };
        };
        build-package = inputs.julia2nix.lib.${system}.buildPackage {
          src = ./.;
          name = "Plot-PackageDeps";
          julia = julia-wrapped;
          extraInstallPhase = ''
          '';
        };

        plot-rs = craneLib.buildPackage {
          src = ./.;
          # cargoExtraArgs = "--target wasm32-wasi";

          # Tests currently need to be run via `cargo wasi` which
          # isn't packaged in nixpkgs yet...
          doCheck = false;
          JULIA_DIR = inputs.julia2nix.packages.${system}.julia_17-bin;
        };
      in {
        packages = {
          default = plot-rs;
          julia = julia-wrapped;
          inherit build-package;
        };
        devShells = import ./devshell {inherit inputs pkgs;};
      })
    )
    // {
      overlays = import ./nix/overlays.nix {inherit inputs;};
    };
}
