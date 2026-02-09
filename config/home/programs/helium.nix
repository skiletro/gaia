{
  lib,
  config,
  pkgs',
  ...
}:
{
  options.erebus.programs.helium.enable = lib.mkEnableOption "Helium Browser";

  config = lib.mkIf config.erebus.programs.helium.enable {
    home.packages = [ pkgs'.helium-bin ];

    xdg.mimeApps.defaultApplications = lib.genAttrs [
      "text/html"
      "application/x-mswinurl"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ] (_v: "helium.desktop");
  };
}
