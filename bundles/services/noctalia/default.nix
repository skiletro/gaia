{
  inputs,
  lib,
  ...
}: {
  home-manager = {config, ...}: {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        # Control panel
        control_center = {
          hidden_tabs = [
            "monitor"
            "power"
          ];
          shortcuts = [
            {
              type = "weather";
            }
            {
              type = "session";
            }
          ];
        };

        # Dock
        dock = {
          enabled = true;
          reserve_space = false;
          show_dots = true;
          smart_auto_hide = true;
          radius = config.stylix.borderRadius;
        };

        wallpaper = {
          transition = ["wipe"];
          transition_duration = 500; # ms
          transition_on_startup = true;
        };

        # night light
        nightlight = {
          enabled = true;
          temperature_night = 3600;
        };

        # Notifs
        notification = {
          border_width = 0.5;
          layer = "overlay";
        };

        # osd
        osd = {
          position = "bottom_center";
          kinds = {
            media = false;
            privacy = false;
          };
          border_width = 0.5;
        };

        # Misc
        theme.pure_black_dark = false;

        location.auto_locate = true;

        audio.sound_theme = "Modern Minimal UI";

        shell = {
          corner_radius_scale = lib.min 2.0 (config.stylix.borderRadius / 12.0);
          date_format = "%A, %-d %B %Y";
          password_style = "random";
          polkit_agent = true;
          screen_time_enabled = true;
          show_location = false;
          time_format = "{:%I:%M%P}";
          greeter_sync.auto_sync = true;
          screen_corners.enabled = false;
          screenshot.save_to_file = false;
          launch_apps_as_systemd_services = true;
          panel = {
            shadow = false;
            control_center_placement = "floating";
            open_near_click_control_center = true;
          };
        };
      };
    };
  };
}
