{
  runCommand,
  makeWrapper,
  gr,
  lib,
  julia_17-bin,
  ...
}: {
  julia ? julia_17-bin,
  makeWrapperArgs ? [],
  GR ? false,
  bin ? "julia",
  ...
} @ args:
runCommand "julia-wrapped" {
  buildInputs = [makeWrapper julia];
  inherit makeWrapperArgs;
  meta.mainProgram = "julia";
} ''
  mkdir -p $out
  makeWrapper ${julia}/bin/julia $out/bin/${bin} \
  ${lib.optionalString GR "--set GRDIR ${gr}"} $makeWrapperArgs
''
