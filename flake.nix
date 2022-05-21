{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-release.url = "github:nixos/nixpkgs/release-21.11";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";

    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";

    nix-filter.url = "github:/numtide/nix-filter";
    nix-filter.inputs.nixpkgs.follows = "nixpkgs";

    cells-lab.url = "github:gtrunsec/DevSecOps-Cells-Lab";
    org-roam-book-template.follows = "cells-lab/org-roam-book-template";
  };

  outputs = {self, ...} @ inputs:
    (inputs.std.growOn {
        inherit inputs;
        cellsFrom = ./cells;
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
        organelles = [
          (inputs.std.installables "packages")

          (inputs.std.runnables "entrypoints")

          (inputs.std.devshells "devshells")
          (inputs.std.functions "devshellProfiles")

          (inputs.std.functions "library")
          (inputs.std.functions "flow")
          (inputs.std.functions "overlays")

          (inputs.std.data "containerJobs")
        ];
      }
      {
        lib = inputs.std.harvest inputs.self ["julia2nix" "library"];
        devShells = inputs.std.harvest inputs.self ["julia2nix" "devshells"];
        overlays = inputs.std.harvest inputs.self ["julia2nix" "overlays"];
      })
    {
      packages.x86_64-linux = (system: {
        inherit
          (inputs.self.${system}.julia2nix.packages)
          julia_16-bin
          julia_17-bin
          gr
          conda
          julia-fhs
          ;

        test-depot = self.lib.${system}.buildDepot {
          depot = ./Depot.nix;
        };

        build-conda = self.lib.${system}.buildEnv {
          src = ./testenv/conda;
          name = "build-conda";
          package = self.packages.${system}.julia-wrapped;
          extraInstallPhase = ''
            mkdir -p $out/conda
            cat > $out/packages/Conda/x2UxR/deps/deps.jl <<EOF
            const ROOTENV = "$out/conda"
            const MINICONDA_VERSION = "3"
            const USE_MINIFORGE = true
            const CONDA_EXE = "$out/conda/bin/conda"
            EOF
          '';
        };

        build-project = self.lib.${system}.buildProject {
          src = inputs.nix-filter.lib.filter {
            root = ./.;
            include = [
              (inputs.nix-filter.lib.inDirectory ./src)
              ./Depot.nix
              ./Project.toml
              ./Manifest.toml
            ];
          };
          name = "Example-Project";
          package = self.lib.${system}.julia-wrapped {
            extraBuildInputs = with inputs.nixpkgs.legacyPackages.${system}; [alejandra nixUnstable nix-prefetch cacert];
            makeWrapperArgs = [
              "--set NIX_PATH nixpkgs=${inputs.nixpkgs.legacyPackages.${system}.path}"
            ];
          };
        };

        julia-wrapped = self.lib.${system}.julia-wrapped {
          package = self.packages.${system}.julia_17-bin;
          enable = {
            GR = true;
            python =
              inputs.nixpkgs.legacyPackages.${system}.python3.buildEnv.override
              {
                extraLibs = with inputs.nixpkgs.legacyPackages.${system}.python3Packages; [xlrd matplotlib pyqt5];
                ignoreCollisions = true;
              };
          };
        };

        build-env = self.lib.${system}.buildEnv {
          src = ./.;
          name = "Example-PackageDeps";
          package = self.packages.${system}.julia-wrapped;
        };
      }) "x86_64-linux";

      packages.aarch64-darwin = (system: {
        inherit
          (inputs.self.${system}.julia2nix.packages)
          julia_18-bin
          ;
      }) "aarch64-darwin";

      packages.x86_64-darwin = (system: {
        inherit (inputs.self.${system}.julia2nix.packages) julia_17-bin julia_18-bin;

        build-project = self.lib.${system}.buildProject {
          src = ./.;
          name = "Example-PackageDeps";
          depot = ./Depot-darwin.nix;
          package = self.lib.${system}.julia-wrapped {
            package = self.packages.${system}.julia_17-bin;
            extraBuildInputs = with inputs.nixpkgs.legacyPackages.${system}; [alejandra nixUnstable nix-prefetch cacert];
            makeWrapperArgs = [
              "--set NIX_PATH nixpkgs=${inputs.nixpkgs.legacyPackages.${system}.path}"
            ];
          };
        };
      }) "x86_64-darwin";
    } {
      templates = {
        devshell = {
          description = "The devshell template which contains several Julia Packages";
          path = ./templates/dev;
        };
        jlrs = {
          description = "The tempalte which contains jlrs development of Nix";
          path = ./templates/jlrs;
        };
      };
    };
}
