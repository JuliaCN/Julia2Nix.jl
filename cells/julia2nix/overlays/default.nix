{
  inputs,
  cell,
}: {
  default = final: prev: {
    lib = prev.lib.extend (
      lfinal: lprev: rec {
        installApp = import ./installApp.nix final;

        buildDepot = args: import ./build/depot.nix final args;

        buildPackage = args: (import ./build final) args;

        installBin = args: (import ./installBin.nix final) args;
      }
    );

    julia-sources = prev.callPackage ../packages/toolchain/_sources/generated.nix {};
  };
}
