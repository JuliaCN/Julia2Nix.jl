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
        ];

      commands = [
        (withCategory "hexagon" {package = nixpkgs.treefmt;})
        {
          name = "mktest";
          category = "tests";
          command = ''
            export NIX_PATH=nixpkgs=${pkgs.path}
            julia --project=$PRJ_ROOT -e 'import Pkg; Pkg.test()'
            julia --project=./. testenv/writeDepot.jl
          '';
          help = "make runtests";
        }
      ];

      packages = with nixpkgs; [
        alejandra
        nodePackages.prettier
        nodePackages.prettier-plugin-toml
      ];

      devshell.startup.nodejs-setuphook =
        l.stringsWithDeps.noDepEntry
        ''
          export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:$NODE_PATH
        '';
    };
  }
