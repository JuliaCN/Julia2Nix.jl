{
  inputs,
  cell,
} @ args: let
in {
  packages = import ./packages.nix args;
  checks = import ./checks.nix args;
  dev = import ./dev.nix args;
  nightly = import ./nightly.nix args;
}
