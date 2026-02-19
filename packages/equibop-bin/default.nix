{
  pkgs,
  lib,
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.equibop-bin) pname version src;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  buildInputs = [ pkgs._7zz ];

  unpackPhase = ''
    7zz x -snld $src
  '';

  installPhase = ''
    mkdir -p $out/Applications
    mv "equibop ${version}-universal/equibop.app" $out/Applications
  '';

  meta.platforms = lib.platforms.darwin;
}
