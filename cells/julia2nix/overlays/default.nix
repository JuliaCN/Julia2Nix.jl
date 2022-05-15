{
  inputs,
  cell,
}: {
  default = final: prev: rec {
    lib = prev.lib.extend (
      lfinal: lprev: rec {
        installApp = import ./installApp.nix final;

        buildDepot = args: import ./build/depot.nix final args;

        buildPackage = args: (import ./build final) args;

        buildProject = {...} @ args:
          (buildPackage args
            // {
            })
          .overrideAttrs (old: {
            preInstall =
              old.preInstall
              + ''
                cp -r ${args.src} $out/src
              '';
            postFixup = ''
              makeWrapper $out/bin/julia $out/bin/julia-project \
              --add-flags "--project=$out/src"
            '';
            meta.mainProgram = "julia-project";
          });
        installBin = args: (import ./installBin.nix final) args;

        julia-wrapped = args: (import ./julia-wrapped.nix final) args;
      }
    );

    julia-sources = prev.callPackage ../packages/toolchain/_sources/generated.nix {};

    patch-sources = prev.callPackage ./patches/_sources/generated.nix {};

    gr = inputs.nixpkgs-release.legacyPackages.${prev.system}.callPackage ./patches/gr.nix {inherit patch-sources;};
  };
}
