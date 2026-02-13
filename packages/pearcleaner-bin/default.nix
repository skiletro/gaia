{
  stdenvNoCC,
  sources,
  lib,
  pkgs,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.pearcleaner-bin) pname version src;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  buildInputs = with pkgs; [
    _7zz
    python313Packages.xattr
  ];

  unpackPhase = ''
    7zz x -snld $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    mv Pearcleaner/Pearcleaner.app $out/Applications
    xattr -c $out/Applications/Pearcleaner.app
  '';

  meta = {
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
