{
  runCommand,
  makeWrapper,
  gr,
  lib,
  julia_19-bin,
  python3,
  symlinkJoin,
  cacert,
  ...
}: {
  package ? julia_19-bin,
  makeWrapperArgs ? [],
  enable ? {},
  meta ? {},
  extraBuildInputs ? [],
  ...
}: let
  enable' =
    lib.recursiveUpdate {
      GR = false;
      python = {};
    }
    enable;

  makeWrapperArgs_ =
    lib.optionals (extraBuildInputs != []) [
      "--prefix PATH : ${lib.makeBinPath extraBuildInputs}"
      "--suffix LD_LIBRARY_PATH ':' ${lib.makeLibraryPath extraBuildInputs}"
    ]
    ++ lib.optionals enable'.GR [
      "--set GRDIR ${gr}"
    ]
    ++ lib.optionals (enable'.python != {}) [
      "--set PYTHON ${enable'.python}/bin/python"
      "--set PYTHONPATH ${enable'.python}/${enable'.python.sitePackages}"
      "--set PYTHONLIB ${enable'.python}/lib/libpython${enable'.python.pythonVersion}.so"
      "--set PYTHONHOME ${enable'.python}"
      "--set PYTHONVERSION ${enable'.python.pythonVersion}"
    ]
    ++ [
      "--set FONTCONFIG_FILE /etc/fonts/fonts.conf"
      "--set JULIA_SSL_CA_ROOTS_PATH ${cacert}/etc/ssl/certs/ca-bundle.crt"
    ]
    ++ makeWrapperArgs;
  meta' =
    lib.recursiveUpdate {
      mainProgram = "julia";
      description = "julia-wrapped mainProgram";
    }
    meta;

  julia-wrapped =
    runCommand "julia-wrapped" {
      buildInputs = [makeWrapper package];
      inherit makeWrapperArgs_;
      meta = meta';
    } ''
      mkdir -p $out
      makeWrapper ${package}/bin/julia $out/bin/${meta'.mainProgram} $makeWrapperArgs_ \
      --set GDK_BACKEND "x11,*"
    '';
in
  symlinkJoin {
    name = "julia";
    paths = [julia-wrapped package];
  }
