{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std self;
  inherit (inputs.nixpkgs) lib;
  inherit (cell) library;
in rec {
  inherit (nixpkgs) julia_17-bin julia_16-bin;
}
