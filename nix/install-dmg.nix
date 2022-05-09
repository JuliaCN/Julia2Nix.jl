{
  stdenv,
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
stdenv.mkDerivation
{
  inherit src pname version;

  buildInputs = [undmg] ++ extraBuildInputs;

  sourceRoot = sourceRoot;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = let
    appname = lib.removeSuffix "-darwin" pname;
  in
    ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -r "${appname}.app" "$out/Applications/${appname}.app"
    ''
    + postInstall;

  meta = {
    platforms = lib.platforms.darwin;
  };
}
