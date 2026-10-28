{
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.jq]; # Required by plugins.

    programs.noctalia.settings = {
      # Plugins
      plugins = {
        enabled = ["ezequiel/mango_layouts"];
        source = [
          {
            name = "community";
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            enabled = true;
          }
        ];
      };

      plugin_settings = {
        "ezequiel/mango_layouts" = {
          list_mode = true;
          panel_placement = "attached";
          panel_position = "center";
          show_center_tile = false;
          show_fair = false;
          show_monocle = false;
          show_right_tile = false;
          show_tile = false;
          show_vertical_deck = false;
          show_vertical_fair = false;
          show_vertical_grid = false;
          show_vertical_scroller = false;
          show_vertical_tile = false;
        };
      };
    };
  };
}
