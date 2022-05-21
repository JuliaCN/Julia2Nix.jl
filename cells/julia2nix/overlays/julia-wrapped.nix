{
  runCommand,
  makeWrapper,
  gr,
  lib,
  julia_17-bin,
  python3,
  ...
}: {
  package ? julia_17-bin,
  makeWrapperArgs ? [],
  enable ? {},
  bin ? "julia",
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
      "--set PYTHONPATH ${enable'.python}/${python3.sitePackages}"
    ]
    ++ makeWrapperArgs;
in
  runCommand "julia-wrapped" {
    buildInputs = [makeWrapper package];
    inherit makeWrapperArgs_;
    meta.mainProgram = bin;
  } ''
    mkdir -p $out
    makeWrapper ${package}/bin/julia $out/bin/${bin} $makeWrapperArgs_
  ''
