{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:/numtide/nix-filter";
  };

  inputs = {
    std-ext.url = "github:gtrunsec/std-ext";
    std.follows = "std-ext/std";
    std-data-collection.follows = "std-ext/std-data-collection";
  };

  outputs = {
    self,
    std,
    ...
  } @ inputs:
    (std.growOn {
        inherit inputs;
        cellsFrom = ./nix;
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
          (functions "workflow")
          (functions "overlays")
          (functions "compiler")

          (data "containerJobs")
        ];
      }
      {
        lib = std.harvest inputs.self ["julia2nix" "lib"];
        devShells = std.harvest inputs.self ["julia2nix" "devshells"];
        overlays = (std.harvest inputs.self ["julia2nix" "overlays"]).x86_64-linux;
        packages = std.harvest inputs.self ["julia2nix" "packages"];
      })
    {
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
