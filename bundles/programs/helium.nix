{
  bundleLib,
  self',
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "helium" ] {

  home-manager = {
    # TODO: configure extensions and other browser settings
    home.packages = [ self'.packages.helium-bin ];

    xdg.mimeApps.defaultApplications = lib.genAttrs [
      "text/html"
      "application/x-mswinurl"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ] (_: "helium.desktop");
  };

}
