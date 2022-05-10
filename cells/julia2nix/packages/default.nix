{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in {
  inherit (nixpkgs) julia_17-bin julia_16-bin;
}
