{
  stdenvNoCC,
  lib,
  symlinkJoin,
  callPackage,
  git,
  writers,
  ...
}: {depot, ...}: let
  depotFile = callPackage depot {};
  srcs = lib.mapAttrs (n: v: let
    path = lib.replaceStrings ["-"] ["/"] n;
    patches = import ./patches.nix {inherit path;};
    name' = lib.last (lib.splitString "-" v.name);
    patch-context = lib.hasAttrByPath ["${name'}"] patches;
  in
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
      installPhase =
        ''
          runHook preInstall

          mkdir -p $out/${n}
          cp -rf --no-preserve=mode,ownership package/* $out/${n}
          runHook postInstall
        ''
        + lib.optionalString patch-context (let
          context = writers.writeBash "update-epgstation" patches."${name'}";
        in ''
          cp -rf --no-preserve=mode,ownership ${context} $out/${n}/patched.bash
        '');
    })
  depotFile.depot;
in
  symlinkJoin {
    name = "julia-depot";
    paths = lib.attrValues srcs;
  }
