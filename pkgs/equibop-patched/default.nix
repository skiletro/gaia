{
  pkgs,
  equibop,
  python313Packages,
  stdenvNoCC,
  lib,
  sources,
  ...
}:
let
  inherit (stdenvNoCC.hostPlatform) isDarwin;

  linuxDerivation = equibop.overrideAttrs (_: {
    postBuild = ''
      pushd build
      ${lib.getExe' python313Packages.icnsutil "icnsutil"} e icon.icns
      popd
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/opt/Equibop
      cp -r dist/*unpacked/resources $out/opt/Equibop/

      for file in build/icon.icns.export/*\@2x.png; do
        base=''${file##*/}
        size=''${base/x*/}
        targetSize=$((size * 2))
        install -Dm0644 $file $out/share/icons/hicolor/''${targetSize}x''${targetSize}/apps/equibop.png
      done

      runHook postInstall
    '';
  });

  darwinDerivation = stdenvNoCC.mkDerivation rec {
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
  };

in
lib.mergeAttrs {
  meta = {
    description = "Chromium-based web browser";
  };
} (if isDarwin then darwinDerivation else linuxDerivation)
