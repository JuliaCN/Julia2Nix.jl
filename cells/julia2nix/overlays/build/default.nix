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
  makeWrapperArgs ? [],
  extraBuildInputs ? [],
  depot ? src + "/Depot.nix",
  precompile ? true,
  extraStartup ? "",
  extraInstallPhase ? "",
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
  depotPath = lib.buildDepot {inherit depot;};
in
  stdenv.mkDerivation {
    name = (lib.importTOML importProject).name or args.name;
    buildInputs = [julia makeWrapper] ++ extraBuildInputs;
    inherit src precompile makeWrapperArgs;

    preInstall = ''
      mkdir -p $out
      mkdir -p $out/{config,conda}

      export HOME=$(pwd)
      echo "Copying dependencies"
      export JULIA_DEPOT_PATH=$out
      cp -r --no-preserve=mode,ownership ${depotPath}/packages $out
      if [ -d "${depotPath}/artifacts" ]; then
      cp -r --no-preserve=mode,ownership ${depotPath}/artifacts $out
      fi

      cp -rf --no-preserve=mode,ownership ${importProject} Project.toml
      cp -rf --no-preserve=mode,ownership ${importManifest} Manifest.toml
    '';
    installPhase = ''
      runHook preInstall

      echo "instantiating Packages"
      # https://github.com/JuliaLang/Pkg.jl/issues/3067
      # https://github.com/GunnarFarneback/LocalRegistry.jl
      # Do we need the local registry instead?
      TMPDIR=$(mktemp -d -p /tmp)


      julia -e ' \
      using Pkg
        Pkg.Registry.add(RegistrySpec(path="${depotPath}/registries/General"))
        Pkg.activate(".")
        Pkg.instantiate()
        '

      ${extraInstallPhase}

      if [[ -n "$precompile" ]]; then
      julia -e ' \
        using Pkg
        Pkg.activate(".")
        Pkg.precompile()
      '
      fi

        # Remove the registry to save space
        julia -e 'using Pkg; Pkg.Registry.rm("General")'

        makeWrapper ${julia}/bin/julia $out/bin/julia \
        --add-flags "-L $out/config/startup.jl" \
        --prefix PATH ":" "${lib.makeBinPath extraBuildInputs}" \
        --suffix JULIA_DEPOT_PATH : "$TMPDIR" $makeWrapperArgs

        runHook postInstall
    '';

    postInstall = ''
      cat > $out/config/startup.jl <<EOF
      push!(Base.DEPOT_PATH, "${placeholder "out"}")
      ${extraStartup}
      EOF
    '';

    meta.mainProgram = "julia";
  }
