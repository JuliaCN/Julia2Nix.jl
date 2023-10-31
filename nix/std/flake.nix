{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:/numtide/nix-filter";
    # TOOD: use the locked prefetch version, will be removed by replacing with nix-prefetch-url
    nixpkgs-lock.url = "github:NixOS/nixpkgs/0cfb3c002b61807ca0bab3efe514476bdf2e5478";
  };

  inputs = {
    omnibus.url = "github:gtrunsec/omnibus";

    std.url = "github:divnix/std";
    std.inputs.nixpkgs.follows = "nixpkgs";
    std.inputs.devshell.follows = "devshell";
    std.inputs.nixago.follows = "nixago";

    devshell.url = "github:numtide/devshell";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "";
  };

  outputs =
    { self, std, ... }@inputs:
    (std.growOn
      {
        inputs = inputs // {
          main = ../..;
        };
        cellsFrom = ./cells;
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
        cellBlocks = with std.blockTypes; [
          (installables "packages")

          (nixago "nixago")

          (runnables "entrypoints")

          (devshells "devshells")
          (functions "devshellProfiles")

          (functions "lib")
          (functions "configs")
          (functions "workflow")
          (functions "overlays")
          (functions "compiler")

          (data "containerJobs")
        ];
      }
      {
        lib = std.harvest inputs.self [
          "julia2nix"
          "lib"
        ];
        devShells = std.harvest inputs.self [
          "julia2nix"
          "devshells"
        ];
        overlays =
          (std.harvest inputs.self [
            "julia2nix"
            "overlays"
          ]).x86_64-linux;
        packages = std.harvest inputs.self [
          "julia2nix"
          "packages"
        ];
      }
    );
}
