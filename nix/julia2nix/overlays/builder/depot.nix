{
  stdenvNoCC,
  lib,
  symlinkJoin,
  callPackage,
  git,
  pkgs,
  writers,
  ...
}: {julia2nix, ...}: let
  fetches = ["fetchzip" "fetchgit" "fetchTarball" "fetchGit"];

  selectFetcher =
    lib.flatten ((attr: (map (name: (lib.optionals (lib.hasAttr name attr) name)) fetches))
      (lib.importTOML julia2nix).depot.${stdenvNoCC.system});

  depots = let
    concatAttrs = let
      f = x:
        lib.foldr
        (n: acc: acc // lib.mapAttrs (_: v: v) (x.${n})) {} (lib.attrNames x);
    in
      f;
  in
    concatAttrs (lib.listToAttrs (map (name: {
        inherit name;
        value = lib.mapAttrs (_: (lib.getAttrFromPath [name]) (pkgs // builtins)) (lib.importTOML julia2nix).depot.${stdenvNoCC.system}."${name}";
      })
      selectFetcher));

  srcs = lib.mapAttrs (n: v: let
    path = lib.replaceStrings ["-"] ["/"] v.name;
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

          mkdir -p $out/${path}
          cp -rf --no-preserve=mode,ownership package/* $out/${path}
          runHook postInstall
        ''
        + lib.optionalString patch-context (let
          context = writers.writeBash "update-epgstation" patches."${name'}";
        in ''
          cp -rf --no-preserve=mode,ownership ${context} $out/${path}/patched.bash
        '');
    })
  depots;
in
symlinkJoin {
  name = "julia-depot";
  paths = lib.attrValues srcs;
}
