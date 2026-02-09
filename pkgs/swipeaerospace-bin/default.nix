{
  sources,
  lib,
  stdenvNoCC,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.swipeaerospace-bin) pname version src;

  unpackPhase = ''
    ${lib.getExe unzip} $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    mv SwipeAeroSpace.app $out/Applications
  '';

  meta = {
    mainProgram = "SwipeAeroSpace";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
