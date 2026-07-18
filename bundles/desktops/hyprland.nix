{
  lib,
  config,
  inputs',
  ...
}:
lib.mkIf (config.gaia.desktop == "hyprland") {

  gaia = {
    programs = {
      vicinae.enable = true;
      suite.enable = true;
    };
    services.noctalia.enable = true;
  };

  nixos = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs'.hyprland.packages.hyprland;
      portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
    };

    security.polkit.enable = true;

    services.displayManager.defaultSession = "hyprland-uwsm";
  };

  home-manager =
    { pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        configType = "hyprlang"; # TODO: convert config to lua :(
        portalPackage = null;
        systemd.enable = false;
        settings =
          let
            pctl = cmd: "${lib.getExe pkgs.playerctl} -p spotify ${cmd}";
          in
          {
            input = {
              kb_layout = "gb";
              follow_mouse = 1;
              sensitivity = 0.6;
              accel_profile = "flat";
            };

            monitorv2 = {
              output = "desc:AOC AG346UCD 2OQQ9JA00068";
              mode = "3440x1440@175";
              position = "0x0";
              scale = "auto";
              bitdepth = 10;
              min_luminance = 0.5;
              max_luminance = 1000;
              max_avg_luminance = 450;
              vrr = 2;
              # TODO: figure out why using the ICC stops transparency from working
              # icc = builtins.fetchurl {
              #   name = "ag346ucd.icm";
              #   url = "https://aoc.com/api/asset/pi35003?ext=icm";
              #   sha256 = "sha256:09lydsnv9csi39gxal4lp408j74ryxviw42cl6k5nf28zgl12c82";
              # };
            };

            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };

            bind = [
              "SUPER, Return, exec, ${lib.getExe pkgs.kitty}"
              "SUPER SHIFT, S, exec, ${lib.getExe pkgs.grimblast} copy area"
              "SUPER, Space, exec, vicinae toggle"
              "SUPER, F, exec, helium"
              "SUPER, E, exec, ${lib.getExe pkgs.nautilus} --new-window"

              "SUPER SHIFT, Q, killactive"
              "SUPER SHIFT, F, fullscreen"
              "SUPER SHIFT, Space, togglefloating"

              "SUPER, P, exec, vicinae deeplink vicinae://launch/@leonkohli/vicinae-extension-process-manager-0/processes"
              "SUPER SHIFT, P, exec, vicinae deeplink vicinae://launch/power"
              "SUPER, Period, exec, vicinae deeplink vicinae://launch/core/search-emojis"
              "SUPER, L, exec, noctalia msg session lock"
              "SUPER SHIFT, L, exec, ${lib.getExe pkgs.hyprpicker} | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"

              "SUPER, Left, movefocus, l"
              "SUPER, Right, movefocus, r"
              "SUPER, Up, movefocus, u"
              "SUPER, Down, movefocus, d"

              "SUPER SHIFT, Left, movewindow, l"
              "SUPER SHIFT, Right, movewindow, r"
              "SUPER SHIFT, Up, movewindow, u"
              "SUPER SHIFT, Down, movewindow, d"

              "SUPER, code:49, togglespecialworkspace" # code:49 = `
              "SUPER SHIFT, code:49, movetoworkspace, special"

              ", XF86PowerOff, exec, noctalia msg session lock"
            ]
            ++ (builtins.concatLists (
              builtins.genList (i: [
                "SUPER, code:1${toString i}, workspace, ${toString (i + 1)}"
                "SUPER SHIFT, code:1${toString i}, movetoworkspace, ${toString (i + 1)}"
              ]) 9
            ));

            bindl = map (command: ", XF86${command}") [
              "AudioRaiseVolume, exec, noctalia msg volume-up"
              "AudioLowerVolume, exec, noctalia msg volume-down"
              "AudioNext, exec, noctalia msg media next"
              "AudioPrev, exec, noctalia msg media previous"
              "AudioPlay, exec, noctalia msg media toggle"
              "Launch9, exec, ${pctl "volume 0.02+"}"
              "Launch8, exec, ${pctl "volume 0.02-"}"
            ];

            bindm = [
              "SUPER, mouse:272, movewindow"
              "SUPER, mouse:273, resizewindow"
            ];

            general = {
              gaps_in = 3;
              gaps_out = 6;
              border_size = 1;
            };

            decoration = {
              rounding = 6;
              rounding_power = 4.0;
              blur = {
                enabled = true;
                size = 3;
                passes = 2;
                noise = 0.05;
                vibrancy = 0.1696;
                popups = true;
                popups_ignorealpha = 0.3;
              };
            };

            dwindle.split_width_multiplier = 1.35;

            layout.single_window_aspect_ratio = "16 9";

            bezier = [
              "defout, 0.16, 1, 0.3, 1"
            ];

            animation = [
              "workspaces, 1, 3, defout, slidefadevert 15%"
              "windows, 1, 1.5, defout, popin"
              "fade, 0"
            ];

            exec-once = map (x: "uwsm app -- ${x}") [
              "${lib.getExe pkgs.tailscale} systray"
              "${lib.getExe' pkgs.udiskie "udiskie"}"
              "${lib.getExe pkgs.wl-clip-persist} --clipboard regular"
              "${lib.getExe pkgs.hyprsunset}"
            ];

            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              focus_on_activate = true;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
              middle_click_paste = false;
            };

            cursor.no_warps = true;

            # layerrule = [
            #   "match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$, ignore_alpha 0.5"
            # ];
            layerrule =
              map (x: "match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$, ${x}")
                [
                  "ignore_alpha 0.5"
                  "no_anim on"
                  "blur on"
                  "blur_popups on"
                ];

            windowrule = [
              "match:class dev.noctalia.Noctalia, size 1080 920"

              "match:class org.freedesktop.impl.portal.desktop.gnome, float on"
              "match:class org.freedesktop.impl.portal.desktop.gnome, size (monitor_w*.60) (monitor_h*.65)"

              "match:class steam, float on"
              ''match:class steam, match:title ^(?!\s*$).+, center on''
              "match:title Steam, float off" # floats everything but the main steam window

              "match:class ^(gsr-ui)$, float on"
              "match:class ^(gsr-ui)$, pin on"
              "match:class ^(gsr-ui)$, move 0 0"

              "match:class helium, suppress_event maximize"
            ]
            ++ [
              "match:tag floater, float on"
              "match:tag floater, center on"
            ]
            ++ (map (x: "match:${x}, tag +floater") [
              "class fsearch"
              "class ^(com.saivert.pwvucontrol)$"
              "class xdg-desktop-portal-gtk"
              "title ^(Open File)(.*)$"
              "title ^(Select a File)(.*)$"
              "title ^(Open Folder)(.*)$"
              "title ^(Save As)(.*)$"
              "title ^(Library)(.*)$"
              "title ^(File Upload)(.*)$"
              "title ^(.*)(wants to save)$"
              "title ^(.*)(wants to open)$"
              "class crashreporter"
              "class org.gnome.FileRoller"
              "class org.gnome.NautilusPreviewer"
              "initial_title ^(Signal Sticker Pack Creator)$"
              "class Emulator" # normally Android emulator
              "class dev.noctalia.Noctalia"
            ]);
          };
      };

      xdg = {
        enable = true;
        autostart.enable = true;
      };

      dconf = {
        enable = lib.mkForce true;
        settings."org/gnome/desktop/wm/preferences".button-layout = lib.mkForce "";
      };
    };

}
