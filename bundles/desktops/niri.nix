{
  lib,
  config,
  inputs,
  ...
}:
lib.mkIf (config.gaia.desktop == "niri") {

  gaia = {
    programs = {
      vicinae.enable = true;
      suite.enable = true;
    };
    services.noctalia.enable = true;
  };

  nixos = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "niri";
        comment = "Niri (uwsm-managed)";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };

    services.displayManager.defaultSession = "niri-uwsm";

    systemd.user.services = {
      niri-flake-polkit.enable = false;
      niri.enableDefaultPath = false;
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };

  home-manager =
    { pkgs, ... }:
    {
      programs.niri.settings = {
        prefer-no-csd = true;

        input = {
          keyboard.xkb.layout = "gb";
          focus-follows-mouse.enable = true;
          mouse = {
            accel-speed = 0.6;
            accel-profile = "flat";
          };
          power-key-handling.enable = false;
        };

        outputs = {
          "AOC AG346UCD 2OQQ9JA00068" = {
            mode = {
              width = 3440;
              height = 1440;
              refresh = 175.0;
            };
            variable-refresh-rate = true;
          };
        };

        layout = {
          always-center-single-column = true;
          gaps = 6;
          focus-ring.width = 1;
          border.enable = true;
          border.width = 1;
          background-color = "transparent";
        };

        cursor.hide-when-typing = true;

        environment = {
          "NIXOS_OZONE_WL" = "1";
          "XDG_CURRENT_DESKTOP" = "niri";
          "XDG_SESSION_DESKTOP" = "niri";
        };

        spawn-at-startup = [
          {
            argv = [
              "${lib.getExe pkgs.tailscale}"
              "systray"
            ];
          }
          { argv = [ "${lib.getExe' pkgs.udiskie "udiskie"}" ]; }
          {
            argv = [
              "${lib.getExe pkgs.wl-clip-persist}"
              "--clipboard"
              "regular"
            ];
          }
        ];

        binds = {
          # App shortcuts
          "Mod+Return".action.spawn = [ "${lib.getExe pkgs.kitty}" ];
          "Mod+Space".action.spawn = [
            "vicinae"
            "toggle"
          ];
          "Mod+F".action.spawn = "helium";
          "Mod+E".action.spawn = [
            "${lib.getExe pkgs.nautilus}"
            "--new-window"
          ];

          # Window management
          "Mod+Shift+Q".action.close-window = { };
          "Mod+Shift+F".action.maximize-column = { };
          "Mod+Ctrl+Shift+F".action.fullscreen-window = { };
          "Mod+Shift+Space".action.toggle-window-floating = { };

          # Vicinae deep links
          "Mod+P".action.spawn = [
            "vicinae"
            "deeplink"
            "vicinae://launch/@leonkohli/vicinae-extension-process-manager-0/processes"
          ];
          "Mod+Shift+P".action.spawn = [
            "vicinae"
            "deeplink"
            "vicinae://launch/power"
          ];
          "Mod+Period".action.spawn = [
            "vicinae"
            "deeplink"
            "vicinae://launch/core/search-emojis"
          ];

          # Lock & screenshot
          "Mod+Delete".action.spawn = [
            "noctalia"
            "msg"
            "session"
            "lock"
          ];
          "Print".action.spawn = [
            "${lib.getExe pkgs.grimblast}"
            "copy"
            "area"
          ];

          # Focus — HJKL (primary)
          "Mod+H".action.focus-column-left = { };
          "Mod+J".action.focus-window-down = { };
          "Mod+K".action.focus-window-up = { };
          "Mod+L".action.focus-column-right = { };

          # Focus — arrows (fallback)
          "Mod+Left".action.focus-column-left = { };
          "Mod+Down".action.focus-window-down = { };
          "Mod+Up".action.focus-window-up = { };
          "Mod+Right".action.focus-column-right = { };

          # Move window — Shift+HJKL (primary)
          "Mod+Shift+H".action.move-column-left = { };
          "Mod+Shift+J".action.move-window-down = { };
          "Mod+Shift+K".action.move-window-up = { };
          "Mod+Shift+L".action.move-column-right = { };

          # Move window — Shift+arrows (fallback)
          "Mod+Shift+Left".action.move-column-left = { };
          "Mod+Shift+Down".action.move-window-down = { };
          "Mod+Shift+Up".action.move-window-up = { };
          "Mod+Shift+Right".action.move-column-right = { };

          # Workspaces
        }
        // (builtins.listToAttrs (
          map (i: {
            name = "Mod+${toString i}";
            value = {
              hotkey-overlay.hidden = true;
              action.focus-workspace = i;
            };
          }) (lib.range 1 9)
        ))
        // (builtins.listToAttrs (
          map (i: {
            name = "Mod+Shift+${toString i}";
            value = {
              hotkey-overlay.hidden = true;
              action.move-column-to-workspace = i;
            };
          }) (lib.range 1 9)
        ))
        // {
          # Media keys (locked — work even when screen is locked)
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "volume-up"
            ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "volume-down"
            ];
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "media"
              "next"
            ];
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "media"
              "previous"
            ];
          };
          "XF86AudioPlay" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "media"
              "toggle"
            ];
          };
          "XF86PowerOff" = {
            allow-when-locked = true;
            repeat = false;
            action.spawn = [
              "noctalia"
              "msg"
              "session"
              "lock"
            ];
          };
        };

        blur = {
          enable = true;
          passes = 2;
          offset = 3.0;
          noise = 0.03;
          saturation = 1.0;
        };

        window-rules = [
          {
            geometry-corner-radius = {
              bottom-left = 6.0;
              bottom-right = 6.0;
              top-left = 6.0;
              top-right = 6.0;
            };
            clip-to-geometry = true;
            background-effect = {
              blur = true;
              xray = false;
            };
          }
          # Noctalia settings window
          {
            matches = [ { app-id = "dev.noctalia.Noctalia"; } ];
            open-floating = true;
            default-column-width.fixed = 1080;
            default-window-height.fixed = 920;
          }

          # Portals — float
          {
            matches = [ { app-id = "org.freedesktop.impl.portal.desktop.gnome"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "xdg-desktop-portal-gtk"; } ];
            open-floating = true;
          }

          # File dialogs — float
          {
            matches = [ { title = "^(Open File)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Select a File)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Open Folder)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Save As)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Library)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(File Upload)(.*)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(.*)(wants to save)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(.*)(wants to open)$"; } ];
            open-floating = true;
          }

          # Apps that should float
          {
            matches = [ { app-id = "fsearch"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "com\\.saivert\\.pwvucontrol"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "crashreporter"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "org\\.gnome\\.FileRoller"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "org\\.gnome\\.NautilusPreviewer"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "^(Signal Sticker Pack Creator)$"; } ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "Emulator"; } ];
            open-floating = true;
          }

          # Steam
          {
            matches = [ { app-id = "steam"; } ];
            open-floating = true;
          }
          {
            matches = [ { title = "Steam"; } ];
            open-floating = false;
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "^noctalia-wallpaper"; } ];
            place-within-backdrop = true;
          }
        ];

        overview.workspace-shadow.enable = false;
      };
    };

}
