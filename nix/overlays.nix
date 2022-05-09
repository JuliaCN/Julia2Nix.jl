{inputs}: {
  default = final: prev: {
    lib = prev.lib.extend (
      lfinal: lprev: {
        installApp = import ./installApp.nix final;
      }
    );

    julia2nix = args:
      prev.callPackage ./build {
        inherit inputs;
        pkgs = prev;
      }
      args;

    julia-sources = prev.callPackage ./toolchain/_sources/generated.nix {};

    julia-bin = args: (prev.callPackage ./installBin.nix {}) args;
  };
}
