{
  lib,
  config,
  inputs,
  ...
}:
lib.mkIf (config.gaia.desktop == "mango") {
  gaia = {
    programs = {
      vicinae.enable = true;
      suite.enable = true;
      rio.enable = true;
    };
    services.noctalia.enable = true;
  };

  nixos = {
    imports = [inputs.mango.nixosModules.mango];

    programs.mango.enable = true;

    programs.uwsm = {
      enable = true;
      waylandCompositors.mango = {
        prettyName = "mango";
        comment = "Mango (uwsm-managed)";
        binPath = "/run/current-system/sw/bin/mango";
      };
    };

    services.displayManager.defaultSession = "mango-uwsm";

    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    security.polkit.enable = true;
  };

  home-manager = {pkgs, ...}: {
    imports = [inputs.mango.hmModules.mango];

    wayland.windowManager.mango = {
      enable = true;

      # uwsm owns the graphical session and imports the environment into
      # systemd; mango's own mango-session.target would be redundant here.
      systemd.enable = false;

      # Called from mango's exec-once. The HM module wraps this in a bash
      # script and adds `exec-once=~/.config/mango/autostart.sh`.
      autostart_sh = ''
        ${lib.getExe pkgs.tailscale} systray &
        ${lib.getExe' pkgs.udiskie "udiskie"} &
        ${lib.getExe pkgs.wl-clip-persist} --clipboard both &
      '';

      settings = {
        # Behaviour
        focus_on_activate = 1;
        sloppyfocus = 1; # focus-follows-mouse
        tag_num = 9;
        warpcursor = 0;

        # Input
        xkb_rules_layout = "gb";
        xkb_rules_options = "ctrl:nocaps";

        mouse_accel_profile = 1; # flat
        mouse_accel_speed = 0.6;

        trackpad_natural_scrolling = 1;
        trackpad_disable_while_typing = 1;
        tap_to_click = 0;
        tap_and_drag = 0;

        # Cursor
        cursor_hide_on_keypress = 1; # hide-when-typing

        # Appearance / layout
        gappih = 6;
        gappiv = 6;
        gappoh = 6;
        gappov = 6;
        borderpx = 1;
        border_radius = 6;
        rootcolor = "0x00000000"; # transparent background (noctalia draws it)

        # Scroller is the closest thing to niri's scrolling layout.
        scroller_structs = 20;
        scroller_default_proportion = 0.5;
        scroller_default_proportion_single = 0.5;
        scroller_ignore_proportion_single = 0;
        scroller_focus_center = 1;
        scroller_prefer_center = 0;
        scroller_prefer_overspread = 0;
        scroller_proportion_preset = "0.5,0.8,1.0";

        # Blur
        blur = 1;
        blur_layer = 1;
        blur_optimized = 1;
        blur_params_radius = 3;
        blur_params_num_passes = 2;
        blur_params_noise = 0.03;
        blur_params_saturation = 1.0;

        # Animations
        animations = 1;
        layer_animations = 1;
        animation_type_open = "slide";
        animation_type_close = "slide";
        animation_duration_open = 250;
        animation_duration_close = 200;
        animation_duration_move = 250;
        animation_duration_tag = 250;
        animation_curve_open = "0.16,1.0,0.3,1.0";
        animation_curve_close = "0.16,1.0,0.3,1.0";
        animation_curve_move = "0.16,1.0,0.3,1.0";
        animation_curve_tag = "0.16,1.0,0.3,1.0";

        # Environment
        env = ["NIXOS_OZONE_WL,1"];

        # Every tag uses the scroller layout, like niri.
        tagrule = ["id:*,layout_name:scroller"];

        # The identifiers below come from niri's output strings. If a monitor
        # is not picked up, run `mmsg get all-monitors` on the running session
        # and replace make/model/serial with the real values.
        monitorrule = [
          # AOC AG346UCD (175 Hz)
          "make:AOC,model:AG346UCD,serial:2OQQ9JA00068,width:3440,height:1440,refresh:175,vrr:1"
          # AOC AG346UCD (100 Hz)
          "make:AOC,model:AG346UCD,serial:0x000002A8,width:3440,height:1440,refresh:100"
          # Laptop panel (moirai)
          "name:^eDP-1$,width:2560,height:1600,refresh:60,scale:1.5,vrr:1"
        ];

        windowrule = [
          # Noctalia settings window
          "isfloating:1,width:1080,height:920,appid:dev.noctalia.Noctalia"

          # Steam notification toasts, bottom-right
          "isfloating:1,offsetx:100,offsety:100,title:^notificationtoasts_\\d+_desktop$,appid:steam"

          # Portals
          "isfloating:1,appid:org\\.freedesktop\\.impl\\.portal\\.desktop\\.gnome"
          "isfloating:1,appid:xdg-desktop-portal-gtk"

          # File dialogs
          "isfloating:1,title:^(Open File)(.*)$"
          "isfloating:1,title:^(Select a File)(.*)$"
          "isfloating:1,title:^(Open Folder)(.*)$"
          "isfloating:1,title:^(Save As)(.*)$"
          "isfloating:1,title:^(Library)(.*)$"
          "isfloating:1,title:^(File Upload)(.*)$"
          "isfloating:1,title:^(.*)(wants to save)$"
          "isfloating:1,title:^(.*)(wants to open)$"

          # Apps
          "isfloating:1,appid:crashreporter"
          "isfloating:1,appid:org\\.gnome\\.FileRoller"
          "isfloating:1,appid:org\\.gnome\\.NautilusPreviewer"
          "isfloating:1,appid:Emulator"
        ];

        layerrule = [
          # Wallpaper already sits behind everything; do not blur it.
          "noblur:1,layer_name:^noctalia-wallpaper$"
        ];

        bind =
          [
            # Apps
            "SUPER,Return,spawn,rio"
            "SUPER,Space,spawn,vicinae toggle"
            "NONE,XF86Search,spawn,vicinae toggle"
            "SUPER,F,spawn,helium"
            "SUPER,E,spawn,${lib.getExe pkgs.nautilus} --new-window"
            "CTRL,Space,spawn,pkill -USR2 -n handy"

            # Window management
            "SUPER+SHIFT,Q,killclient"
            "SUPER+SHIFT,F,togglemaximizescreen"
            "SUPER+CTRL+SHIFT,F,togglefullscreen"
            "SUPER+SHIFT,Space,togglefloating"

            # Scroller width (mango cycles presets instead of +/- steps)
            "SUPER,Minus,switch_proportion_preset"
            "SUPER,Equal,switch_proportion_preset"

            # Vicinae / noctalia
            "SUPER,P,spawn,vicinae deeplink vicinae://launch/@leonkohli/vicinae-extension-process-manager-0/processes"
            "SUPER+SHIFT,P,spawn,vicinae deeplink vicinae://launch/power"
            "SUPER,Period,spawn,vicinae deeplink vicinae://launch/core/search-emojis"
            "SUPER,Delete,spawn,noctalia msg session lock"
            "SUPER+SHIFT,S,spawn,noctalia msg screenshot-region"

            # Focus window
            "SUPER,H,focusdir,left"
            "SUPER,J,focusdir,down"
            "SUPER,K,focusdir,up"
            "SUPER,L,focusdir,right"
            "SUPER,Left,focusdir,left"
            "SUPER,Down,focusdir,down"
            "SUPER,Up,focusdir,up"
            "SUPER,Right,focusdir,right"

            # Move window
            "SUPER+SHIFT,H,exchange_client,left"
            "SUPER+SHIFT,J,exchange_stack_client,next"
            "SUPER+SHIFT,K,exchange_stack_client,prev"
            "SUPER+SHIFT,L,exchange_client,right"
            "SUPER+SHIFT,Left,exchange_client,left"
            "SUPER+SHIFT,Down,exchange_stack_client,next"
            "SUPER+SHIFT,Up,exchange_stack_client,prev"
            "SUPER+SHIFT,Right,exchange_client,right"
          ]
          ++ (map (i: "SUPER,${toString i},view,${toString i},0") (lib.range 1 9))
          ++ (map (i: "SUPER+SHIFT,${toString i},tag,${toString i},0") (lib.range 1 9));

        # Locked binds, work even while the screen is locked
        bindl = [
          "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
          "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
          "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
          "NONE,XF86AudioMicMute,spawn,noctalia msg mic-mute"
          "NONE,XF86AudioNext,spawn,noctalia msg media next"
          "NONE,XF86AudioPrev,spawn,noctalia msg media previous"
          "NONE,XF86AudioPlay,spawn,noctalia msg media toggle"
          "NONE,XF86PowerOff,spawn,noctalia msg session lock"
          "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up current"
          "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down current"
        ];
      };
    };
  };
}
