{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  default =
    let
      libPath = nixpkgs.lib.makeLibraryPath [ ];
    in
    nixpkgs.mkShell {
      shellHook = ''
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${libPath}" \
      '';
    };
}
