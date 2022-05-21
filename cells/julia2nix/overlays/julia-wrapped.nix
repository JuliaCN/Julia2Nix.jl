{
  runCommand,
  makeWrapper,
  gr,
  lib,
  julia_17-bin,
  python3,
  ...
}: {
  julia ? julia_17-bin,
  makeWrapperArgs ? [],
  pythonEnv ? {},
  GR ? false,
  bin ? "julia",
  extraBuildInputs ? [],
  ...
}: let
  makeWrapperArgs_ =
    lib.optionals (extraBuildInputs != []) [
      "--prefix PATH : ${lib.makeBinPath extraBuildInputs}"
      "--suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath extraBuildInputs}"
    ]
    ++ lib.optionals GR [
      "--set GRDIR ${gr}"
    ]
    ++ lib.optionals (pythonEnv != {}) [
      "--set PYTHON ${pythonEnv}/bin/python"
      "--set PYTHONPATH ${pythonEnv}/${python3.sitePackages}"
    ]
    ++ makeWrapperArgs;
in
  runCommand "julia-wrapped" {
    buildInputs = [makeWrapper julia];
    inherit makeWrapperArgs_;
    meta.mainProgram = bin;
  } ''
    mkdir -p $out
    makeWrapper ${julia}/bin/julia $out/bin/${bin} $makeWrapperArgs_
  ''
