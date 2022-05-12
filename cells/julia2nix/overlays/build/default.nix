{
  stdenv,
  julia_17-bin,
  runCommand,
  makeWrapper,
  lib,
  python3,
  cacert,
  git,
  ...
}: {
  julia ? julia_17-bin,
  extraLibs ? [],
  src,
  importManifest ? src + "/Manifest.toml",
  importProject ? src + "/Project.toml",
  makeWrapperArgs ? "",
  extraBuildInputs ? [],
  depot ? src + "/Depot.nix",
  precompile ? true,
  ...
} @ args: let
  # Extra libraries for Julia's LD_LIBRARY_PATH.
  # Recent Julia packages that use Artifacts.toml to specify their dependencies
  # shouldn't need this.
  # But if a package implicitly depends on some library being present at runtime, you can
  # add it here.
  # extraLibs = [ ];
  # Wrapped Julia with libraries and environment variables.
  # Note: setting The PYTHON environment variable is recommended to prevent packages
  # from trying to obtain their own with Conda.
  julia-wrapped = runCommand "julia-wrapped" {buildInputs = [makeWrapper];} ''
    mkdir -p $out/bin
    makeWrapper ${julia}/bin/julia $out/bin/julia \
                --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLibs}" \
                --set PYTHON ${python3}/bin/python
  '';
  depotPath = lib.buildDepot {inherit depot;};
in
  stdenv.mkDerivation {
    name = (lib.importTOML importProject).name or args.name;
    buildInputs = [julia-wrapped makeWrapper git cacert] ++ extraBuildInputs;
    inherit src precompile;

    installPhase = ''
      runHook preInstall

        mkdir -p $out
        export HOME=$(pwd)
        echo "Copying dependencies"
        export JULIA_DEPOT_PATH=$out
        cp -r ${depotPath}/packages $out
        cp -r ${depotPath}/artifacts $out

        cp -rf --no-preserve=mode,ownership ${importProject} Project.toml
        cp -rf --no-preserve=mode,ownership ${importManifest} Manifest.toml

        echo "instantiating Packages"
        julia -e ' \
        using Pkg
          Pkg.Registry.add(RegistrySpec(path="${depotPath}/registries/General"))
          Pkg.activate(".")
          Pkg.instantiate()
          '

          if [[ -n "$precompile" ]]; then
          julia -e ' \
            using Pkg
            Pkg.activate(".")
            Pkg.precompile()
          '
        fi

          julia -e ' \
            using Pkg
            # Remove the registry to save space
            Pkg.Registry.rm("General")
            '

            makeWrapper ${julia}/bin/julia $out/bin/julia \
            --suffix JULIA_DEPOT_PATH : "${depotPath}" $makeWrapperArgs

            runHook postInstall
    '';
  }
