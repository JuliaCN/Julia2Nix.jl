{
  stdenvNoCC,
  lib,
  symlinkJoin,
  callPackage,
  git,
  ...
}: {depot, ...}: let
  depotFile = callPackage depot {};
  srcs = lib.mapAttrs (n: v:
    stdenvNoCC.mkDerivation {
      name = n;
      src = v;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      sourceRoot = ".";
      unpackPhase = ''
        unpackDir="$TMPDIR/unpack"
        unpackFile "$src"
        cp -r "$src" "package"
      '';
      installPhase = ''
        runHook preInstall

        mkdir -p $out/${n}
        cp -r package/* $out/${n}

        runHook postInstall
      '';
    })
  depotFile.depot;
in
  symlinkJoin {
    name = "julia-depot";
    paths = lib.attrValues srcs;
  }
