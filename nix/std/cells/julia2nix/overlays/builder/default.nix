{
  stdenv,
  julia_19-bin,
  runCommand,
  makeWrapper,
  lib,
  ...
}:
{
  package ? julia_19-bin,
  extraLibs ? [ ],
  src,
  importManifest ? src + "/Manifest.toml",
  importProject ? src + "/Project.toml",
  extraBuildInputs ? [ ],
  julia2nix ? src + "/julia2nix.toml",
  precompile ? true,
  extraInstallPhase ? "",
  extraStartup ? "",
  makeWrapperArgs ? [ ],
  extraDepot ? { },
  saveRegistry ? false,
  ...
}@args:
let
  # Extra libraries for Julia's LD_LIBRARY_PATH.
  # Recent Julia packages that use Artifacts.toml to specify their dependencies
  # shouldn't need this.
  # But if a package implicitly depends on some library being present at runtime, you can
  # add it here.
  # extraLibs = [ ];
  # Wrapped Julia with libraries and environment variables.
  # Note: setting The PYTHON environment variable is recommended to prevent packages
  # from trying to obtain their own with Conda.
  depotPath = lib.buildDepot (
    lib.recursiveUpdate { inherit julia2nix; } extraDepot
  );
in
stdenv.mkDerivation {
  name = (lib.importTOML importProject).name or args.name;
  buildInputs = [ makeWrapper ] ++ extraBuildInputs;
  inherit
    src
    precompile
    makeWrapperArgs
    depotPath
  ;

  preInstall = ''
    mkdir -p $out
    mkdir -p $out/config

    export HOME=$(pwd)
    echo "Copying dependencies"
    export JULIA_DEPOT_PATH=$out
    cp -rf --no-preserve=mode,ownership ${depotPath}/packages $out
    if [ -d "${depotPath}/artifacts" ]; then
    cp -rf --no-preserve=mode,ownership ${depotPath}/artifacts $out
    fi

    cp -rf --no-preserve=mode,ownership ${importProject} Project.toml
    cp -rf --no-preserve=mode,ownership ${importManifest} Manifest.toml

    cat > $out/startup.jl <<EOF
    push!(Base.DEPOT_PATH, "${placeholder "out"}")
    import Pkg
    Pkg.activate("${src}")
    ${extraStartup}
    EOF
  '';
  installPhase = ''
     runHook preInstall

     echo "instantiating Packages"

     ${extraInstallPhase}

     #exec patched.bash
     for i in $(find $out/* -iname 'patched.bash' -type l); do
         bash $i
     done

     ${package}/bin/julia -e ' \
     using Pkg
       Pkg.Registry.add(RegistrySpec(path="${depotPath}/registries/General"))
       Pkg.activate(".")
       Pkg.instantiate()
       '

     # https://github.com/JuliaLang/Pkg.jl/issues/3067
     # https://github.com/GunnarFarneback/LocalRegistry.jl
     # Do you need the local registry instead?
     TMPDIR=$(mktemp -d -p /tmp)


     makeWrapper ${package}/bin/julia $out/bin/julia \
     --add-flags "-L $out/startup.jl" \
     --suffix JULIA_DEPOT_PATH : $TMPDIR $makeWrapperArgs

    # make sure the patchShebangs replaces the shebangs with the $out/bin/julia path
    export PATH=$out/bin:$PATH
    patchShebangs --build $out/bin

    if [[ -n "$precompile" ]]; then
    $out/bin/julia -e ' \
      using Pkg
      Pkg.activate(".")
      Pkg.precompile()
    '
    fi

    runHook postInstall
  '';

  postFixup = ''
    # Remove the registry to save space
    ${lib.optionalString (!saveRegistry) ''
      julia -e 'using Pkg; Pkg.Registry.rm("General")'
    ''}
  '';
  meta.mainProgram = "julia";
}
