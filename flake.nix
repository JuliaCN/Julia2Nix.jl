{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-release.url = "github:nixos/nixpkgs/release-22.05";

    nix-filter.url = "github:/numtide/nix-filter";
    nix-filter.inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs = {
    cells-lab.url = "github:gtrunsec/cells-lab";
    std.follows = "cells-lab/std";
    org-roam-book-template.follows = "cells-lab/org-roam-book-template";
  };

  outputs = {
    self,
    std,
    cells-lab,
    ...
  } @ inputs:
    (std.growOn {
        inherit inputs;
        cellsFrom = ./cells;
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
        organelles = [
          (std.installables "packages")

          (std.runnables "entrypoints")

          (std.devshells "devshells")
          (std.functions "devshellProfiles")

          (std.functions "library")
          (std.functions "workflow")
          (std.functions "overlays")
          (std.functions "compiler")

          (std.data "containerJobs")
        ];
      }
      {
        lib = std.harvest inputs.self ["julia2nix" "library"];
        devShells = std.harvest inputs.self ["julia2nix" "devshells"];
        overlays = std.harvest inputs.self ["julia2nix" "overlays"];
      })
    {
      packages.x86_64-linux = (system: {
        inherit
          (inputs.self.${system}.julia2nix.packages)
          julia_16-bin
          julia_17-bin
          julia_18-bin
          gr
          conda
          julia-fhs
          ;

        build-depot = self.lib.${system}.buildDepot {
          julia2nix = ./julia2nix.toml;
        };

        build-conda = self.lib.${system}.buildEnv {
          src = ./testenv/conda;
          name = "build-conda";
          package = self.packages.${system}.julia-wrapped;
          extraInstallPhase = with inputs.nixpkgs.legacyPackages.${system}; ''
          '';
        };

        build-project = self.lib.${system}.buildProject {
          src = inputs.nix-filter.lib.filter {
            root = ./.;
            include = [
              (inputs.nix-filter.lib.inDirectory ./src)
              ./julia2nix.toml
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
          saveRegistry = true;
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

        julia2nix = inputs.cells-lab.${system}._writers.library.writeShellApplication {
          name = "julia2nix";
          runtimeInputs = [self.packages.${system}.build-project];
          text = ''
            julia ${./testenv/writejulia2nix.jl} ${system}
          '';
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
          julia2nix = ./julia2nix.toml;
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
