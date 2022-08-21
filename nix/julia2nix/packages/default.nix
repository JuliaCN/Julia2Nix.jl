{
  inputs,
  cell,
}: let
  inherit (inputs) std self;
  inherit (inputs.nixpkgs) lib;
  inherit (cell) library;

  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
in {
  inherit (nixpkgs) julia_16-bin gr conda;

  julia-fhs = nixpkgs.julia-fhs "julia" "julia";

  julia_17-bin = (version:
    (lib.optionalAttrs (nixpkgs.system == "x86_64-linux") nixpkgs.julia_17-bin)
    // lib.optionalAttrs (nixpkgs.system == "x86_64-darwin" || nixpkgs.system == "aarch64-darwin")
    (library.installApp {
      inherit version;
    })
    // lib.optionalAttrs (nixpkgs.system == "aarch64-linux") (library.installBin {
      inherit version;
    })) "17-release";

  julia_18-bin = (version:
    lib.optionalAttrs (nixpkgs.system == "aarch64-darwin" || nixpkgs.system == "x86_64-darwin") (library.installApp {
      inherit version;
    })
    // lib.optionalAttrs (nixpkgs.system == "x86_64-linux" || nixpkgs.system == "aarch64-linux") (library.installBin {
      inherit version;
    })) "18-release";
}
