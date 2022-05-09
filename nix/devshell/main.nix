{
  pkgs,
  inputs,
  ...
}:
pkgs.devshell.mkShell ({
  extraModulesPath,
  lib,
  ...
}: {
  name = "Julia2Nix.jl";
  imports = [
    "${extraModulesPath}/git/hooks.nix"
    (pkgs.devshell.importTOML ./main.toml)
    (import ./packages.nix inputs)
  ];

  commands = [
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

  packages = with pkgs; [
    julia_17-bin
    nixUnstable
    nix-prefetch
    nixpkgs-fmt
    cacert # Needed for network access
    alejandra
    nodePackages.prettier
    nodePackages.prettier-plugin-toml
  ];
  devshell.startup.nodejs-setuphook =
    lib.stringsWithDeps.noDepEntry
    ''
      export NODE_PATH=${pkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:$NODE_PATH
    '';
})
