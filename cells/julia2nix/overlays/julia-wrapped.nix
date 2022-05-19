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
  ...
}: let
  makeWrapperArgs_ =
    [
      "--set GRDIR ${gr}"
    ]
    ++ makeWrapperArgs
    ++ lib.optionals (pythonEnv != {}) [
      "--set PYTHON ${pythonEnv}/bin/python"
      "--set PYTHONPATH ${pythonEnv}/${python3.sitePackages}"
    ];
in
  runCommand "julia-wrapped" {
    buildInputs = [makeWrapper julia];
    inherit makeWrapperArgs_;
    meta.mainProgram = bin;
  } ''
    mkdir -p $out
    makeWrapper ${julia}/bin/julia $out/bin/${bin} $makeWrapperArgs_
  ''
