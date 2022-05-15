{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-release.url = "github:nixos/nixpkgs/release-21.11";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";

    std.url = "github:gtrunsec/std/custom";
    std.inputs.nixpkgs.follows = "nixpkgs";
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
          julia_17-bin
          julia_16-bin
          gr
          ;

        test-depot = self.lib.${system}.buildDepot {
          depot = ./Depot.nix;
        };

        build-project = self.lib.${system}.buildProject {
          src = ./.;
          name = "Example-Project";
          extraBuildInputs = with inputs.nixpkgs.legacyPackages.${system}; [alejandra nixUnstable nix-prefetch cacert];
          makeWrapperArgs = [
            "--set NIX_PATH nixpkgs=${inputs.nixpkgs.legacyPackages.${system}.path}"
          ];
        };

        julia-wrapped = self.lib.${system}.julia-wrapped {
          julia = self.packages.${system}.julia_17-bin;
          GR = true;
        };

        build-package = self.lib.${system}.buildPackage {
          src = ./.;
          name = "Example-PackageDeps";
          julia = self.packages.${system}.julia-wrapped;
        };

        julia_18-beta-bin = inputs.self.${system}.julia2nix.library.installBin {
          inherit system;
          version = "18-beta";
        };
      }) "x86_64-linux";

      packages.aarch64-darwin = (system: {
        julia_18-beta-bin = inputs.self.${system}.julia2nix.library.installApp {
          inherit system;
          version = "18-beta";
        };
      }) "aarch64-darwin";

      packages.x86_64-darwin = (system: {
        julia_18-beta-bin = inputs.self.${system}.julia2nix.library.installApp {
          inherit system;
          version = "18-beta";
        };
        julia_17-bin = inputs.self.${system}.julia2nix.library.installApp {
          inherit system;
          version = "17-release";
        };

        build-package = self.lib.${system}.buildPackage {
          src = ./.;
          name = "Example-PackageDeps";
          depot = ./Depot-darwin.nix;
          julia = self.packages.${system}.julia_17-bin;
        };
      }) "x86_64-darwin";
    } {
      templates = {
        devshell = {
          description = "The devshell template which contains several Julia Packages";
          path = ./templates/dev;
        };
      };
    };
}
