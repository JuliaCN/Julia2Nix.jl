{
  stdenv,
  lib,
  autoPatchelfHook,
  julia_17-bin,
  julia-sources,
  system,
  ...
}: {version}:
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
  meta = {
    mainProgram = "julia";
    description = "${version}: High-level, high-performance, dynamic language for technical computing";
  };
}
