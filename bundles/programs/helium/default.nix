{
  lib,
  inputs,
  ...
}: {
  nixos = {pkgs, ...}: {
    imports = [inputs.helium.nixosModules.default];

    nixpkgs.overlays = [inputs.helium.overlays.default];

    programs.helium = {
      enable = true;
      package = pkgs.helium-wv;
      flags = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandUnscaledTouchpadScrolling"
      ];
    };
  };

  home-manager = {
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
