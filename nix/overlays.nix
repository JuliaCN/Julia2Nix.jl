{inputs}: {
  default = final: prev: {
    lib = prev.lib.extend (
      lfinal: lprev: {
        installApp = import ./install-dmg.nix prev;
      }
    );

    julia2nix = args:
      prev.callPackage ./build {
        inherit inputs;
        pkgs = prev;
      }
      args;

    julia-sources = prev.callPackage ./toolchain/_sources/generated.nix {};

    julia_18-beta-bin = source: prev.callPackage ./bin-18-beta.nix {inherit source;};
  };
}
