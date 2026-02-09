{
  stdenvNoCC,
  sources,
  lib,
  pkgs,
  ...
}:
let
  linuxDerivation = pkgs.proton-pass;

  darwinDerivation = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit (sources.protonpass-bin) pname version src;

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
      mv "ProtonPass_${finalAttrs.version}/Proton Pass.app" $out/Applications
    '';

    meta = {
      platforms = lib.platforms.darwin;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  });
in
with pkgs.stdenvNoCC.hostPlatform;
(if isDarwin then darwinDerivation else linuxDerivation)
