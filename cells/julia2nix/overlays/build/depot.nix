{
  lib,
  stdenvNoCC,
  symlinkJoin,
  fetchurl,
  fetchgit,
  fetchzip,
}:
with builtins;
with lib;
  {depotFile}: let
    inherit (stdenvNoCC.targetPlatform.parsed) cpu vendor kernel abi;

    srcs =
      mapAttrs
      (kind: paths:
        mapAttrs
        (
          path: meta: let
            isArchive = meta.type == "archive";
            isGit = meta.type == "git";
            src =
              if isArchive
              then
                # fetchzip { name = meta.name; inherit (meta) url sha256; extension="tar.gz"; stripRoot=false; }
                fetchurl {
                  inherit (meta) sha256;
                  url = "${meta.url}";
                  name = "source";
                }
              # fetchurl { sha256=meta.origsha256; url="${meta.url}"; name = "source"; }
              else
                fetchgit {
                  name = "source";
                  inherit (meta) url;
                };
          in
            stdenvNoCC.mkDerivation (
              (
                if isArchive
                then {
                  inherit (meta) version;
                  pname = meta.name;
                }
                else {inherit (meta) name;}
              )
              // {
                inherit src;
                dontConfigure = true;
                dontBuild = true;
                sourceRoot = ".";
                unpackPhase = ''
                  unpackDir="$TMPDIR/unpack"
                  mkdir "$unpackDir"
                  cd "$unpackDir"
                  renamed="$TMPDIR/source.tar.gz"
                  cp -r "$src" "$renamed"
                  unpackFile "$renamed"
                  chmod -R +w "$unpackDir"
                '';
                installPhase = ''
                  runHook preInstall
                  # mkdir -p "$out/${path}"
                  # mv ./* "$out/${path}"
                  # mkdir $out
                  # mv ./* $out
                  # cp -r . $out
                  mkdir -p "$out/$(dirname "${path}")"
                  mv "$unpackDir" "$out/${path}"

                  runHook postInstall
                '';
              }
            )
        )
        paths)
      depot';
  in
    symlinkJoin {
      name = "julia-depot";
      paths =
        # attrValues srcs.registries
        attrValues srcs.packages
        ++ attrValues srcs.artifacts;
    }
