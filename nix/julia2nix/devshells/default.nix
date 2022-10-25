{
  inputs,
  cell,
} @ args: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std self;
in
  l.mapAttrs (_: std.lib.dev.mkShell) {
    default = {extraModulesPath, ...}: {
      name = "Julia2Nix";

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
          cell.devshellProfiles.nightly
          cell.devshellProfiles.checks
          cell.devshellProfiles.update
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
          command = "julia --project=$PRJ_ROOT $PRJ_ROOT/testenv/writejulia2nix.jl ${nixpkgs.system}";
          help = "write julia2nix.toml";
        }
        {
          name = "buildProject";
          category = "tests";
          command = "nix run .#packages.${nixpkgs.system}.build-project --print-build-logs -- testenv/writejulia2nix.jl ${nixpkgs.system}";
          help = "write julia2nix.toml with buildProject";
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

    update = {...}: {
      imports = [
        cell.devshellProfiles.update
      ];
      # github CI issue: nvfetcher encoding problem
      env = [
        {
          name = "LC_ALL";
          value = "en_US.UTF-8";
        }
      ];
    };
  }
