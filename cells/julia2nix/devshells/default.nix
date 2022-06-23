{
  inputs,
  cell,
} @ args: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std self;
  withCategory = category: attrset: attrset // {inherit category;};
in
  l.mapAttrs (_: std.std.lib.mkShell) {
    default = {
      extraModulesPath,
      pkgs,
      ...
    }: {
      name = "Julia2Nix";

      std.docs.enable = false;
      std.adr.enable = false;

      git.hooks = {
        enable = true;
        # pre-commit.text = builtins.readFile ./pre-flight-check.sh;
      };

      imports =
        [
          std.std.devshellProfiles.default
          "${extraModulesPath}/git/hooks.nix"
          (inputs.std.inputs.devshell.lib.importTOML ./main.toml)
        ]
        ++ [
          cell.devshellProfiles.packages
          cell.devshellProfiles.checks
        ];

      commands = [
        {
          name = "mktest";
          category = "tests";
          command = ''
            julia --project=$PRJ_ROOT -e 'import Pkg; Pkg.test()'
            # julia --project=./. testenv/writeDepot.jl
          '';
          help = "make runtests";
        }
        {
          name = "writeDepot";
          category = "tests";
          command =
            l.optionalString pkgs.stdenv.buildPlatform.isDarwin ''
              julia --project=./. testenv/writeDepotDarwin.jl
            ''
            + l.optionalString pkgs.stdenv.buildPlatform.isLinux ''
              julia --project=./. testenv/writeDepot.jl
            '';
          help = "write Depot.nix";
        }
        {
          name = "nvfetcher-update";
          command = ''
            nix develop github:GTrunSec/cells-lab#devShells.x86_64-linux.update \
            --refresh --command \
            nvfetcher-update cells/julia2nix/apps/toolchain/sources.toml
          '';
        }
      ];

      env = [
        {
          name = "NIX_PATH";
          value = "nixpkgs=${pkgs.path}";
        }
      ];
    };
    packages = {pkgs, ...}: {
      imports = [
        cell.devshellProfiles.packages
      ];
    };
  }
