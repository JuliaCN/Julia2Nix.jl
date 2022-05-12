{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
          ;
        test-depot = self.lib.${system}.buildDepot {
          depot = ./Depot.nix;
        };
        build = self.lib.${system}.buildPackage {
          src = ./.;
          name = "Ju";
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
