{
  config,
  inputs',
  pkgs',
  lib,
  ...
}:
{
  stylix = {
    cursor = {
      package =
        with config.lib.stylix.colors.withHashtag;
        inputs'.cursors.packages.bibata-modern-cursor.override {
          background_color = base00;
          outline_color = base06;
          accent_color = base00;
        };
      name = "Bibata-Modern-Custom";
      size = 24;
    };

    opacity = {
      applications = 0.75;
      popups = 0.75;
      terminal = 0.75;
    };

    targets.qt.enable = false; # https://github.com/nix-community/stylix/issues/1946
  };

  home-manager.sharedModules = lib.singleton {
    xdg.configFile."stylix/wall.png".source = config.stylix.image;

    stylix.icons = {
      enable = true;
      package = pkgs'.morewaita-icon-theme;
      dark = "MoreWaita";
      light = "MoreWaita";
    };

  };
}
