{
  stdenv,
  lib,
  autoPatchelfHook,
  julia_17-bin,
  julia-sources,
  ...
}: {
  version,
  system,
}:
stdenv.mkDerivation {
  inherit (julia-sources."julia-${version}-${system}") src pname version;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dontStrip = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    mv {bin,etc,include,lib,libexec,share} $out

    runHook postInstall
  '';
  meta.mainProgram = "julia";
}
