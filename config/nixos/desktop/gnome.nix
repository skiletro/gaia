{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  options.erebus.desktop.gnome.enable = lib.mkEnableOption "Gnome desktop and accompanying programs.";

  imports = [ self.nixosModules.gnome ];

  config = lib.mkIf config.erebus.desktop.gnome.enable {
    services.desktopManager.gnome = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        accent-directories
        appindicator
        color-picker
        dash-to-dock
        gsconnect
        keep-awake
        mpris-label
        search-light
        smile-complementary-extension
        tiling-assistant
        weather-oclock
      ];
      thumbnailers = with pkgs; [
        ffmpegthumbnailer # fixes video thumbnails without totem
        nufraw-thumbnailer # for raw images
        gnome-epub-thumbnailer # for epub and mobi books
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

      settings = {
        pinned-apps = [
          "zen-twilight.desktop"
          "org.gnome.Nautilus.desktop"
          "proton-mail.desktop"
          # "com.mitchellh.ghostty.desktop"
          "discord.desktop"
          "spotify.desktop"
          "steam.desktop"
          "FFPWA-01234567892E23DB21B95DEF0A.desktop" # instagram-pwa
          "writer.desktop"
          "calc.desktop"
        ];

        custom-keybindings = [
          {
            binding = "<Super>Return";
            command = "kitty";
            name = "Launch Terminal";
          }

          {
            binding = "<Super>period";
            command = "smile";
            name = "Open Emoji Picker";
          }

          {
            binding = "Launch9"; # F18
            command = "${lib.getExe pkgs.playerctl} -p spotify volume 0.02+";
            name = "Spotify Volume Up";
          }

          {
            binding = "Launch8"; # F17
            command = "${lib.getExe pkgs.playerctl} -p spotify volume 0.02-";
            name = "Spotify Volume Down";
          }
          {
            binding = "<Shift><Alt>F9";
            command = "gsr-ui-cli replay-save";
            name = "Capture Replay with GSR UI";
          }
          {
            binding = "<Super>z";
            command = "gsr-ui-cli toggle-show";
            name = "Launch GSR UI";
          }
        ];
      };

      dconf-settings = {
        "org/gnome/mutter" = {
          attach-modal-dialogs = false;
          center-new-windows = true;
          dynamic-workspaces = true;
          edge-tiling = true;
          experimental-features = [
            "scale-monitor-framebuffer"
            "variable-refresh-rate"
          ];
        };

        "org/gnome/TextEditor" = {
          restore-session = false;
          style-variant = "light";
        };

        "org/gnome/desktop/interface" = {
          accent-color = "pink"; # Set this to whatever matches the colour scheme best.
          clock-format = "12h";
          clock-show-weekday = true;
          enable-animations = true;
          enable-hot-corners = false;
          gtk-enable-primary-paste = false;
        };

        "org/gnome/desktop/media-handling" = {
          autorun-never = true;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.7;
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          two-finger-scrolling-enabled = true;
        };

        "org/gnome/desktop/wm/preferences" = {
          auto-raise = true;
          button-layout = "close,minimize,maximize:";
          focus-mode = "click";
          num-workspaces = 1;
          resize-with-right-button = true;
        };

        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.gvariant.mkTuple [
              "xkb"
              "gb"
            ])
          ];
          xkb-options = [ ];
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          home = [ "<Super>e" ];
          www = [ "<Super>f" ];
          calculator = [ "<Super>c" ];
        };

        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Shift><Super>s" ];
        };

        "org/gnome/desktop/wm/keybindings" = {
          close = [ "<Shift><Super>q" ];
          show-desktop = [ "<Shift><Super>d" ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          minimize = [ "<Shift><Super>c" ];
          move-to-workspace-1 = [ "<Shift><Super>1" ];
          move-to-workspace-2 = [ "<Shift><Super>2" ];
          move-to-workspace-3 = [ "<Shift><Super>3" ];
          move-to-workspace-4 = [ "<Shift><Super>4" ];
          move-to-workspace-5 = [ "<Shift><Super>5" ];
          toggle-fullscreen = [ "<Shift><Super>f" ];
        };

        # Extensions
        # Tray
        "org/gnome/shell/extensions/appindicator" = {
          icon-opacity = 255;
          icon-size = 0;
          legacy-tray-enabled = false;
          tray-pos = "right";
        };

        # Dash to Dock
        "org/gnome/shell/extensions/dash-to-dock" = {
          click-action = "minimize-or-previews";
          dash-max-icon-size = 40;
          disable-overview-on-startup = true;
          dock-fixed = false;
          dock-position = "LEFT";
          extend-height = false;
          height-fraction = 0.9;
          icon-size-fixed = true;
          intellihide-mode = "ALL_WINDOWS";
          middle-click-action = "quit";
          preview-size-scale = 0.0;
          running-indicator-style = "DOT";
          scroll-action = "do-nothing";
          shift-click-action = "launch";
          shift-middle-click-action = "launch";
          show-apps-at-top = false;
          show-mounts = true;
          show-mounts-only-mounted = true;
          show-show-apps-button = false;
          show-trash = false;
          hot-keys = false;
        };

        "org/gnome/shell/extensions/mpris-label" = {
          divider-string = " - ";
          extension-place = "center";
          icon-padding = 5;
          left-click-action = "play-pause";
          left-padding = 0;
          middle-click-action = "none";
          mpris-sources-blacklist = "Mozilla zen,Mozilla zen-twilight,Chromium";
          right-click-action = "open-menu";
          right-padding = 0;
          second-field = "";
          show-icon = "left";
          thumb-backward-action = "none";
          thumb-forward-action = "none";
          use-whitelisted-sources-only = false;
          extension-index = 0;
        };

        # Search Light
        "org/gnome/shell/extensions/search-light" = {
          "shortcut-search" = [ "<Super>space" ];
          "secondary-shortcut-search" = [ "<Super>d" ];
          "popup-at-cursor-monitor" = true;
        };

        # Smile (Emoji Selector)
        "it/mijorus/smile" = {
          is-first-run = false;
          load-hidden-on-startup = true;
        };

        # Color Picker
        "org/gnome/shell/extensions/color-picker" = {
          enable-shortcut = true;
          color-picker-shortcut = [ "<Super>l" ];
          enable-systray = false;
        };
      };
    };
  };
}
