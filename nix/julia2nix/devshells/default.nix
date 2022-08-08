{
  inputs,
  cell,
} @ args: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std self;
  withCategory = category: attrset: attrset // {inherit category;};
in
  l.mapAttrs (_: std.std.lib.mkShell) {
    default = {extraModulesPath, ...}: {
      name = "Julia2Nix";

      std.docs.enable = false;
      std.adr.enable = false;

      git.hooks = {
        enable = true;
        # pre-commit.text = builtins.readFile ./pre-flight-check.sh;
      };

      nixago = [
        cell.nixago.treefmt
      ];

      imports =
        [
          std.std.devshellProfiles.default
          "${extraModulesPath}/git/hooks.nix"
          (inputs.std.inputs.devshell.lib.importTOML ./main.toml)
        ]
        ++ [
          cell.devshellProfiles.packages
          cell.devshellProfiles.checks
        ]
        ++ l.optionals nixpkgs.stdenv.buildPlatform.isLinux [
          cell.devshellProfiles.dev
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
          name = "writejulia2nix";
          category = "tests";
          command = "julia --project=./. testenv/writejulia2nix.jl ${nixpkgs.system}";
          help = "write julia2nix.toml";
        }
        {
          name = "buildProject";
          category = "tests";
          command = "nix run .#packages.${nixpkgs.system}.build-project --print-build-logs -- testenv/writejulia2nix.jl ${nixpkgs.system}";
          help = "write julia2nix.toml with buildProject";
        }
        {
          name = "nvfetcher-update";
          command = ''
            nix develop github:GTrunSec/cells-lab#devShells.x86_64-linux.update \
            --refresh --command \
            nvfetcher-update nix/julia2nix/packages/toolchain/sources.toml
          '';
        }
      ];

      env = [
        {
          name = "NIX_PATH";
          value = "nixpkgs=${nixpkgs.path}";
        }
      ];
    };
    packages = {pkgs, ...}: {
      imports = [
        cell.devshellProfiles.packages
      ];
    };
  }
