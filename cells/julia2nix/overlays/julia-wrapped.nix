{
  runCommand,
  makeWrapper,
  gr,
  lib,
  ...
}: {
  julia,
  makeWrapperArgs ? [],
  GR,
  ...
} @ args:
runCommand "julia-wrapped" {
  buildInputs = [makeWrapper];
  inherit makeWrapperArgs;
  meta.mainProgram = "julia";
} ''
  mkdir -p $out
  makeWrapper ${julia}/bin/julia $out/bin/julia \
  ${lib.optionalString GR "--set GRDIR ${gr}"} $makeWrapperArgs
''
