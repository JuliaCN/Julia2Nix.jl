{
  stdenvNoCC,
  lib,
  symlinkJoin,
  callPackage,
  git,
  fetchzip,
  writers,
  ...
}: {julia2nix, ...}: let
  depots = lib.mapAttrs (_: fetchzip) (lib.importTOML julia2nix).depot.${stdenvNoCC.system}.fetchzip;

  srcs = lib.mapAttrs (n: v: let
    path = v.name;
    patches = import ./patches.nix {inherit path;};
    name' = lib.last (lib.splitString "-" n);
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
  depots;
in
  symlinkJoin {
    name = "julia-depot";
    paths = lib.attrValues srcs;
  }
