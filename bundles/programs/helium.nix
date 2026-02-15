{ self', lib, ... }:
{
  home-manager = {
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
