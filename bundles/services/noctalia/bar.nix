{
  home-manager = {config, ...}: {
    programs.noctalia.settings = {
      # Status bar
      bar = {
        default = {
          start = [
            "workspaces"
          ];
          center = [
            "weather"
            "group:g2"
          ];
          end = [
            "tray"
            "group:g1"
          ];
          capsule = true;
          capsule_radius = config.stylix.borderRadius;
          radius = config.stylix.borderRadius;
          capsule_fill = "surface";
          contact_shadow = false;
          margin_ends = 0;
          padding = 4;
          position = "left";
          shadow = false;
          capsule_group = [
            {
              enabled = true;
              fill = "surface";
              id = "g1";
              members = [
                "caffeine"
                "bluetooth"
                "notifications"
                "volume"
                "network"
                "battery"
              ];
              opacity = 1.0;
              padding = 6.0;
            }
            {
              enabled = true;
              fill = "surface";
              id = "g2";
              members = [
                "clock"
                "date"
              ];
              opacity = 1.0;
              padding = 6.0;
            }
          ];
        };
      };

      # Status bar widgets
      widget = {
        clock = {
          anchor = true;
          format = "{:%I:%M}";
        };
        date = {
          color = "on_surface_variant";
          format = "{:%d\\n%m\\n%y}";
        };
        network = {
          interactive = false;
          show_label = false;
          actions.left = "panel-toggle control-center network";
        };
        tray = {
          drawer = true;
          pinned = ["Steam"];
        };
        volume = {
          show_label = false;
        };
        workspaces = {
          empty_color = "surface_variant";
          active_pill_size = 1.5;
          inactive_pill_size = 1.5;
          occupied_color = "surface_variant";
          scale = 1.25;
          hide_when_empty = true;
        };
      };
    };
  };
}
