{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";

    std.url = "github:gtrunsec/std/custom";
    std.inputs.nixpkgs.follows = "nixpkgs";

    data-merge.url = "github:divnix/data-merge";
    data-merge.inputs.nixpkgs.follows = "nixpkgs";
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
          (inputs.std.functions "library")
          (inputs.std.functions "flow")
          (inputs.std.functions "overlays")
          (inputs.std.devshells "devshells")
          (inputs.std.devshells "containerJobs")
          (inputs.std.devshells "devshellProfiles")
          (inputs.std.installables "packages")
        ];
      }
      {
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
    };
}
