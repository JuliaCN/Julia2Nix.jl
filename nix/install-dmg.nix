{
  stdenvNoCC,
  lib,
  fetchurl,
  undmg,
  ...
}: {
  pname,
  version,
  src,
  postInstall ? "",
  sourceRoot ? ".",
  extraBuildInputs ? [],
  ...
}:
stdenvNoCC.mkDerivation
{
  inherit src pname version;

  buildInputs = [undmg] ++ extraBuildInputs;

  sourceRoot = sourceRoot;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = let
    appname = "Julia-${version}";
  in
    ''
      runHook preInstall

      mkdir -p "$out/Applications"
      cp -r "${appname}.app" "$out/Applications/${appname}.app"
      ln -s $out/Applications/${appname}.app/Contents/Resources/julia/bin $out/bin

      runHook postInstall
    ''
    + postInstall;

  meta = {
    platforms = lib.platforms.darwin;
  };
}
