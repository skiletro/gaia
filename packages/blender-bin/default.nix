{
  stdenvNoCC,
  fetchurl,
  lib,
  pkgs,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "blender";
  version = "4.5.3";

  src = fetchurl {
    url = "https://ftp.halifax.rwth-aachen.de/blender/release/Blender4.5/blender-4.5.3-macos-arm64.dmg";
    sha256 = "sha256-c+qEEFO1VAS7OnGpoiNm8fiCF4f+XImfi1Wn//kp0Bs=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  buildInputs = with pkgs; [
    _7zz
  ];

  unpackPhase = ''
    7zz x -snld $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    mv Blender/Blender.app $out/Applications
  '';

  meta = {
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
