{
  inputs,
  cell,
} @ args: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std self;
in {
  packages = import ./packages.nix args;
  checks = import ./checks.nix args;
}
