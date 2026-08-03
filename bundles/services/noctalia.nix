{ bundleLib, inputs, ... }:
bundleLib.mkEnableModule [ "gaia" "services" "noctalia" ] {

  home-manager = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {

        # Status bar
        bar = {
          default = {
            capsule = true;
            capsule_fill = "surface";
            center = [
              "weather"
              "clock"
              "audio_visualizer"
            ];
            contact_shadow = true;
            end = [
              "tray"
              "group:g1"
              "group:g2"
            ];
            margin_ends = 250;
            padding = 4;
            position = "left";
            shadow = false;
            start = [ "workspaces" ];
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
                ];
                opacity = 1.0;
                padding = 6.0;
              }
              {
                enabled = true;
                fill = "surface_variant";
                id = "g2";
                members = [
                  "battery"
                  "brightness"
                ];
                opacity = 1.0;
                padding = 6.0;
              }
            ];
          };
        };

        # Status bar widgets
        widget = {
          audio_visualizer = {
            color_2 = "secondary";
            mirrored = false;
            show_when_idle = true;
          };
          clock = {
            anchor = true;
            format = "{:%I:%M}";
          };
          network = {
            interactive = false;
            show_label = false;
          };
          tray = {
            drawer = true;
            pinned = [ "Steam" ];
          };
          volume = {
            show_label = false;
          };
          workspaces = {
            active_pill_size = 2.0;
            empty_color = "surface_variant";
            inactive_pill_size = 1.5;
            occupied_color = "surface_variant";
            scale = 1.25;
          };
        };

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
        };

        # Idle behaviour (autolocking)
        idle = {
          behavior_order = [
            "lock"
            "screen-off"
            "lock-and-suspend"
          ];
          pre_action_fade_seconds = 5;
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 600.0;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = false;
              timeout = 900.0;
            };
            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 660.0;
            };
          };
        };

        # Lockscreen
        lockscreen = {
          blurred_desktop = true;
          fingerprint = false;
        };

        # night light
        nightlight = {
          enabled = true;
          temperature_night = 3600;
        };

        # Notifs
        notification.layer = "overlay";

        # osd
        osd = {
          position = "bottom_center";
          kinds = {
            media = false;
            privacy = false;
          };
        };

        # Misc
        theme.pure_black_dark = true;
        plugins.enabled = [ ];

        shell = {
          date_format = "%A, %-d %B %Y";
          password_style = "random";
          polkit_agent = true;
          screen_time_enabled = true;
          show_location = false;
          time_format = "{:%I:%M%P}";
          greeter_sync.auto_sync = true;
          screen_corners = {
            enabled = true;
            size = 20;
          };
          screenshot.save_to_file = false;
          launch_apps_as_systemd_services = true;
        };
      };
    };
  };

}
