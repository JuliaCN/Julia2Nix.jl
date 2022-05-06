{
  pkgs,
  inputs,
  ...
}:
pkgs.devshell.mkShell ({extraModulesPath, ...}: {
  name = "julia2nix.jl";
  imports = [
    "${extraModulesPath}/git/hooks.nix"
  ];

  packages = with pkgs; [
    julia_17-bin
    nixUnstable
    nix-prefetch
    nixpkgs-fmt
    cacert # Needed for network access
  ];
})
