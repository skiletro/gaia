{
  sources,
  lib,
  pkgs,
  ...
}:
let
  linuxDerivation = pkgs.protonvpn-gui;

  darwinDerivation = pkgs.stdenvNoCC.mkDerivation {
    inherit (sources.protonvpn-bin) pname version src;

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
      mv ProtonVPN/ProtonVPN.app $out/Applications
    '';

    meta = {
      platforms = lib.platforms.darwin;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
with pkgs.stdenvNoCC.hostPlatform;
(if isDarwin then darwinDerivation else linuxDerivation)
