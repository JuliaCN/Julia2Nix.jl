{
  inputs,
  cell,
}: {
  default = final: prev: {
    lib = prev.lib.extend (
      lfinal: lprev: {
        installApp = import ./installApp.nix final;
        julia2nix = args:
          import ./build {
            inherit inputs;
            pkgs = prev;
          }
          args;
        installBin = args: (import ./installBin.nix final) args;
      }
    );

    julia-sources = prev.callPackage ../packages/toolchain/_sources/generated.nix {};
  };
}
