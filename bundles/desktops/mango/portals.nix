{lib, ...}: {
  nixos = {pkgs, ...}: {
    xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings.screencast = {
          chooser_type = "simple";
          chooser_cmd = lib.getExe' pkgs.wlr-utils "wlr-chooser";
        };
      };
      xdgOpenUsePortal = false;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config = {
        common = {
          # Defaults https://mangowm.github.io/docs/configuration/xdg-portals
          default = ["gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };
    };
  };
}
