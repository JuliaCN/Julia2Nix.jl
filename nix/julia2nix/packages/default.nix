{
  inputs,
  cell,
}: let
  inherit (inputs) std self;

  l = inputs.nixpkgs.lib // builtins;

  nixpkgs = inputs.nixpkgs.appendOverlays [
    cell.overlays.default
  ];
in {
  inherit (nixpkgs) julia_16-bin gr conda;

  julia-fhs = nixpkgs.julia-fhs "julia" "julia";

  julia_17-bin = (version:
    l.optionalAttrs (nixpkgs.system == "x86_64-darwin" || nixpkgs.system == "aarch64-darwin")
    (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "aarch64-linux" || nixpkgs.system == "x86_64-linux") (cell.lib.installBin {
      inherit version;
    })) "17-release";

  julia_18-bin = (version:
    l.optionalAttrs (nixpkgs.system == "aarch64-darwin" || nixpkgs.system == "x86_64-darwin") (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "x86_64-linux" || nixpkgs.system == "aarch64-linux") (cell.lib.installBin {
      inherit version;
    })) "18-release";

  julia_nightly-bin = (version:
    l.optionalAttrs (nixpkgs.system == "aarch64-darwin" || nixpkgs.system == "x86_64-darwin") (cell.lib.installApp {
      inherit version;
    })
    // l.optionalAttrs (nixpkgs.system == "x86_64-linux" || nixpkgs.system == "aarch64-linux") (cell.lib.installBin {
      inherit version;
    })) "nightly-19";
}
