{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
  n2c = inputs.nixpkgs.appendOverlays [
    (
      _final: _prev: {
        inherit
          (inputs.nix2container.packages)
          nix2containerUtil
          skopeo-nix2container
          nix2container
          ;
      }
    )
  ];
in {
  inherit (nixpkgs.lib) installBin installApp buildDepot buildPackage buildProject julia-wrapped;
  inherit n2c;
}
