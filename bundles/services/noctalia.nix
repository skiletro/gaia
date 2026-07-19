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

        lockscreen_widgets = {
          enabled = true;
          schema_version = 2;
          widget_order = [
            "lockscreen-login-box@DP-3"
            "lockscreen-widget-0000000000000001"
            "lockscreen-widget-0000000000000003"
          ];
          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };
          widget = {
            "lockscreen-login-box@DP-3" = {
              box_height = 96.0;
              box_width = 448.0;
              cx = 1720.0;
              cy = 768.0;
              output = "DP-3";
              rotation = 0.0;
              type = "login_box";
              settings = {
                background_color = "surface_variant";
                background_opacity = 0.0;
                background_radius = 0.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                show_caps_lock = false;
                show_keyboard_layout = false;
                show_login_button = false;
                show_password_hint = false;
              };
            };
            lockscreen-widget-0000000000000001 = {
              box_height = 160.0;
              box_width = 384.0;
              cx = 1720.0;
              cy = 640.0;
              output = "DP-3";
              rotation = 0.0;
              type = "clock";
              settings = {
                background = false;
                center_text = true;
                clock_style = "digital";
                shadow = true;
              };
            };
            lockscreen-widget-0000000000000003 = {
              box_height = 304.0;
              box_width = 416.0;
              cx = 1720.0;
              cy = 1240.0;
              output = "DP-3";
              rotation = -0.0;
              type = "media_player";
              settings = {
                background = false;
                hide_when_no_media = true;
                layout = "vertical";
                shadow = true;
              };
            };
          };
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
