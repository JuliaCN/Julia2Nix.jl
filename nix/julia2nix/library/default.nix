{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
in {
  inherit (nixpkgs.lib) installBin installApp buildDepot buildEnv buildProject julia-wrapped;

  /*
  patches ["a" "b"]
  */
  # patches = list: ;
}
