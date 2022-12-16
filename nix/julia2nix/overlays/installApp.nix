{
  stdenvNoCC,
  lib,
  fetchurl,
  undmg,
  julia-sources,
  system,
  ...
}: {
  version,
  postInstall ? "",
  sourceRoot ? ".",
  extraBuildInputs ? [],
  ...
}: let
  version' = import ./version.nix { inherit lib version julia-sources system;};
in
  stdenvNoCC.mkDerivation {
    pname = lib.elemAt (lib.splitString "-" julia-sources."julia-${version}-${system}".pname) 0;
    inherit (julia-sources."julia-${version}-${system}") src;
    version = version'.default;

    buildInputs = [undmg] ++ extraBuildInputs;

    inherit sourceRoot;

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
        cp -r *.app "$out/Applications"
        ln -s $out/Applications/*.app/Contents/Resources/julia/bin $out/bin

      ''
      + postInstall;

    meta = {
      platforms = lib.platforms.darwin;
      mainProgram = "julia";
      description = "${version}: High-level, high-performance, dynamic language for technical computing";
    };
  }
