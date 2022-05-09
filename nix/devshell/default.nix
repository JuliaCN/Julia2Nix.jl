{
  pkgs,
  inputs,
  ...
} @ args: {
  default = import ./main.nix args;
}
