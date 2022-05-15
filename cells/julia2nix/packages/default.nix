{
  inputs,
  cell,
}: let
  inherit (inputs) std self;
  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
  inherit (inputs.nixpkgs) lib;
  inherit (cell) library;
in rec {
  inherit (nixpkgs) julia_17-bin julia_16-bin gr;
}
