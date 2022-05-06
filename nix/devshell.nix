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
  name = "julia2nix.jl";
  imports = [
    "${extraModulesPath}/git/hooks.nix"
    (pkgs.devshell.importTOML ./commands.toml)
  ];

  packages = with pkgs; [
    julia_17-bin
    nixUnstable
    nix-prefetch
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
