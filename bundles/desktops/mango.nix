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

  home-manager = {
    pkgs,
    config,
    ...
  }: let
    colors = config.lib.stylix.colors;
    withAlpha = alpha: color: "0x${color}${alpha}";
    opaque = withAlpha "ff";
    mmsg = lib.getExe' config.wayland.windowManager.mango.package "mmsg";

    # Auto layout on the ultrawide: a lone tiled window centers at the mfact
    # width (roughly 16:9); two or more windows go back to plain tile. mango
    # has no count-conditional layout, so watch the IPC and dispatch
    # setlayout on the focused monitor when the count changes. Only acts on
    # monitors with an aspect ratio of 2.0 or wider, leaves tags already on
    # other layouts (scroller, monocle, ...) alone, and holds off while a
    # client is maximized or fullscreen, since setlayout clears those states.
    layoutWatcher = pkgs.writers.writePython3 "mango-layout-watcher" {} ''
      import json
      import subprocess
      import sys

      mmsg = sys.argv[1]


      def blocked(mon_name):
          out = subprocess.run(
              [mmsg, "get", "all-clients"], capture_output=True, text=True
          ).stdout
          for c in json.loads(out).get("clients", []):
              if (
                  c.get("monitor") == mon_name
                  and c.get("is_visible")
                  and (c.get("is_maximized") or c.get("is_fullscreen"))
              ):
                  return True
          return False


      def corrections(mon):
          if mon["width"] / mon["height"] < 2.0:
              return
          for tag in mon.get("tags", []):
              if not tag.get("is_active"):
                  continue
              layout = tag.get("layout")
              count = tag.get("client_count", 0)
              if count == 1 and layout == "T":
                  yield "center_tile"
              elif count > 1 and layout == "CT":
                  yield "tile"


      def handle(event):
          for mon in event.get("monitors", []):
              if not mon.get("active"):
                  continue
              cmds = list(corrections(mon))
              if not cmds or blocked(mon["name"]):
                  continue
              for layout in cmds:
                  subprocess.run([mmsg, "dispatch", "setlayout," + layout])


      for line in sys.stdin:
          line = line.strip()
          if not line:
              continue
          try:
              handle(json.loads(line))
          except (json.JSONDecodeError, KeyError, TypeError, ValueError):
              continue
    '';
  in {
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

        # Dynamic single-window layout (see layoutWatcher).
        ${layoutWatcher} ${mmsg} &

        # Hot reload. home-manager replaces ~/.config/mango/config.conf with a
        # symlink to a new store path on every switch. Watch the directory and
        # dispatch reload_config so mango picks the new file up without a
        # restart, the way niri reloads its config automatically.
        (
          ${lib.getExe' pkgs.inotify-tools "inotifywait"} -m -q \
            -e close_write,moved_to,create --format '%f' \
            "$HOME/.config/mango" |
            while read -r changed; do
              if [ "$changed" = "config.conf" ]; then
                sleep 0.3
                ${mmsg} dispatch reload_config
              fi
            done
        ) &
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

        # center_tile places the stack fully beside the master instead of
        # splitting it around a centered master, so stacked windows keep a
        # usable width. mfact for the 16:9-ish lone master comes from the AOC
        # tagrule below, not from here.
        center_when_single_stack = 0;

        # Stylix (rose-pine) colours
        focuscolor = opaque colors.base0D;
        bordercolor = opaque colors.base03;
        urgentcolor = opaque colors.base08;
        dropcolor = withAlpha "55" colors.base0D;
        splitcolor = opaque colors.base09;
        maximizescreencolor = opaque colors.base0B;
        scratchpadcolor = opaque colors.base0C;
        globalcolor = opaque colors.base0A;
        overlaycolor = opaque colors.base0E;
        shadowscolor = opaque colors.base00;

        # Overview jump labels and monocle group bar
        jump_label_decorate_bg_color = opaque colors.base01;
        jump_label_decorate_border_color = opaque colors.base0D;
        jump_label_decorate_fg_color = opaque colors.base05;
        jump_label_decorate_focus_bg_color = opaque colors.base0D;
        jump_label_decorate_focus_fg_color = opaque colors.base00;
        group_bar_decorate_bg_color = opaque colors.base01;
        group_bar_decorate_border_color = opaque colors.base0D;
        group_bar_decorate_fg_color = opaque colors.base05;
        group_bar_decorate_focus_bg_color = opaque colors.base0D;
        group_bar_decorate_focus_fg_color = opaque colors.base00;

        # Scroller is the closest thing to niri's scrolling layout.
        scroller_structs = 20;
        scroller_default_proportion = 0.5;
        scroller_default_proportion_single = 0.5;
        scroller_ignore_proportion_single = 0;
        scroller_focus_center = 1;
        scroller_prefer_center = 0;
        scroller_prefer_overspread = 0;
        scroller_proportion_preset = "0.5,0.8,1.0";

        # Blur. Layer blur is on so layer-shell launchers (vicinae) get a
        # blurred backdrop. Noctalia's shell surfaces render their own
        # background and mango's layer blur does not filter by surface
        # opacity, so those layers are excluded via layerrule below (see the
        # Noctalia Mango integration docs).
        blur = 1;
        blur_layer = 1;
        blur_optimized = 1;
        blur_params_radius = 3;
        blur_params_num_passes = 2;
        blur_params_noise = 0.03;
        blur_params_saturation = 1.0;

        # Window shadows (Noctalia draws its own layer shadows)
        shadows = 1;
        layer_shadows = 0;
        shadow_only_floating = 0;
        shadows_size = 4;
        shadows_blur = 12;
        shadows_position_x = 2;
        shadows_position_y = 2;

        # Animations. Tag switches animate vertically.
        animations = 1;
        layer_animations = 0;
        tag_animation_direction = 0;
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

        # On the 3440x1440 ultrawide, center_tile caps a single window at the
        # mfact width (roughly 16:9) and centers it instead of stretching it
        # across the screen like the default tile layout does. Everything
        # without a matching rule (the 16:10 laptop panel) keeps plain tile.
        # The tag 4 scroller rule comes after so it wins on both monitors.
        tagrule = [
          "id:*,monitor_make:AOC,layout_name:center_tile,mfact:0.74"
          "id:4,layout_name:scroller"
        ];

        # No compositor blur on noctalia's shell layers (bar, dock, panel,
        # notifications, osd, wallpaper): they render their own background and
        # layer blur smears the wallpaper behind them.
        layerrule = ["noblur:1,layer_name:^noctalia"];

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

            # Resize window (niri: set-column-width / set-window-height ±5%,
            # stepped in pixels here). resizewin moves the split for tiled
            # windows, the proportion in scroller, and the size when floating.
            "SUPER,Minus,resizewin,-60,0"
            "SUPER,Equal,resizewin,+60,0"
            "SUPER+SHIFT,Minus,resizewin,0,-60"
            "SUPER+SHIFT,Equal,resizewin,0,+60"

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

        # The user config replaces /etc/mango/config.conf wholesale (mango
        # only reads the system config when the user config is missing), and
        # nothing besides Ctrl+Alt+F1-12 is compiled in, so the mouse, wheel
        # and touchpad bindings from the shipped default are restored here.
        mousebind = [
          "SUPER,btn_left,moveresize,curmove"
          "NONE,btn_middle,togglemaximizescreen,0"
          "SUPER,btn_right,moveresize,curresize"
        ];

        axisbind = [
          "SUPER,UP,viewtoleft_have_client"
          "SUPER,DOWN,viewtoright_have_client"
        ];

        gesturebind = [
          "none,left,3,focusdir,left"
          "none,right,3,focusdir,right"
          "none,up,3,focusdir,up"
          "none,down,3,focusdir,down"
          "none,right,4,viewprev_have_client"
          "none,left,4,viewnext_have_client"
          "none,up,4,enteroverview"
          "none,down,4,leaveoverview"
        ];
      };
    };
  };
}
