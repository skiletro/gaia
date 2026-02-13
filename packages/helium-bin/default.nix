{
  stdenvNoCC,
  stdenv,
  sources,
  lib,
  pkgs,
  ...
}:
let
  inherit (stdenvNoCC.hostPlatform) isDarwin;

  linuxDerivation = stdenvNoCC.mkDerivation rec {
    inherit (sources.helium-tarball) pname version src;

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      gcc.cc.lib
      stdenv.cc.cc.lib
      libx11
      libxext
      libxcb
      libxcomposite
      libxdamage
      libxfixes
      libxrandr
      glib
      at-spi2-core
      nspr
      nss
      dbus
      systemd
      cups
      expat
      libxkbcommon
      alsa-lib
      mesa
      cairo
      pango
      qt6.qtbase
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
           
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/256x256/apps
           
      cp -r helium-${version}-x86_64_linux/* $out/bin/

      cp "helium-${version}-x86_64_linux/helium.desktop" $out/share/applications/helium.desktop

      cp "helium-${version}-x86_64_linux/product_logo_256.png" $out/share/icons/hicolor/256x256/apps/helium.png

      runHook postInstall
    '';

    postInstall = ''
      # Make the desktop file executable and fix any paths if necessary
      chmod +x $out/share/applications/helium.desktop
    '';

    autoPatchelfIgnoreMissingDeps = [
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
    ];

    meta.mainProgram = "helium";
  };

  darwinDerivation = stdenvNoCC.mkDerivation {
    inherit (sources.helium-dmg) pname version src;

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
      mv Helium.app $out/Applications
    '';

  };
in
lib.mergeAttrs {
  meta = {
    description = "Chromium-based web browser";
  };
} (if isDarwin then darwinDerivation else linuxDerivation)
