{
  lib,
  stdenvNoCC,
  gtk3,
  xdg-utils,
  sources,
  ...
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  inherit (sources.morewaita-icon-theme) pname version src;

  postPatch = ''
    patchShebangs install.sh
  '';

  nativeBuildInputs = [
    gtk3
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    THEMEDIR="$out/share/icons/MoreWaita" ./install.sh

    runHook postInstall
  '';

  meta = {
    description = "Adwaita style extra icons theme for Gnome Shell";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = with lib.licenses; [ gpl3Only ];
    platforms = lib.platforms.linux;
  };
})
