{
  inputs,
  cell,
}: {
  default = final: prev: rec {
    lib = prev.lib.extend (
      lfinal: lprev: rec {
        installApp = import ./installApp.nix final;

        buildDepot = args: import ./build/depot.nix final args;

        buildEnv = args: (import ./build final) args;

        buildProject = {...} @ args:
          (buildEnv args
            // {
            })
          .overrideAttrs (old: {
            preInstall =
              old.preInstall
              + ''
                cp -r ${args.src} $out/src
              '';

            makeWrapperArgs = ["--add-flags --project=${placeholder "out"}/src"];
          });

        installBin = args: (import ./installBin.nix final) args;

        julia-wrapped = args: (import ./julia-wrapped.nix final) args;
      }
    );

    julia-sources = prev.callPackage ../packages/toolchain/_sources/generated.nix {};

    patch-sources = prev.callPackage ./patches/_sources/generated.nix {};

    gr = inputs.nixpkgs-release.legacyPackages.${prev.system}.callPackage ./patches/gr.nix {inherit patch-sources;};
    conda = prev.callPackage ./patches/conda.nix {};
  };
}
