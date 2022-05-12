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
  extraStartup ? "",
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

    preInstall = ''
      mkdir -p $out
      mkdir -p $out/config

      export HOME=$(pwd)
      echo "Copying dependencies"
      export JULIA_DEPOT_PATH=$out
      cp -r ${depotPath}/packages $out
      cp -r ${depotPath}/artifacts $out

      cp -rf --no-preserve=mode,ownership ${importProject} Project.toml
      cp -rf --no-preserve=mode,ownership ${importManifest} Manifest.toml
    '';
    installPhase = ''
      runHook preInstall

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

        # Remove the registry to save space
        julia -e 'using Pkg; Pkg.Registry.rm("General")'

        # https://github.com/JuliaLang/Pkg.jl/issues/3067
        # https://github.com/GunnarFarneback/LocalRegistry.jl
        # Do you need the local registry instead?
        TMPDIR=$(mktemp -d -p /tmp)

        makeWrapper ${julia}/bin/julia $out/bin/julia \
        --add-flags "-L $out/config/startup.jl" \
        --suffix JULIA_DEPOT_PATH : "$TMPDIR" $makeWrapperArgs

        runHook postInstall
    '';

    postInstall = ''
      cat > $out/config/startup.jl <<EOF
      push!(Base.DEPOT_PATH, "${depotPath}")
      ${extraStartup}
      EOF
    '';

    meta.mainProgram = "julia";
  }
