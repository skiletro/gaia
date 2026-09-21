{
  lib,
  config,
  inputs,
  inputs',
  ...
}: let
  # dwindle picks the split axis from the focused window's aspect ratio, so on
  # a 21:9 monitor it keeps making columns until the third split (|V|V|V&H|).
  # dwindle_aspect_threshold biases that axis: above 1.0 new windows stack
  # sooner on very wide monitors. The 1.25 default is a no-op on 16:9 and
  # 16:10 displays because their window aspect ratios never enter the 1.0 to
  # 1.25 band, so no per-host configuration is needed. Upstream default 1.0
  # keeps the unpatched behavior.
  mango-aspect-threshold = inputs'.mango.packages.mango.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./dwindle-aspect-threshold.patch];
  });
in
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

      # Patched with dwindle_aspect_threshold; see comment at the top of the file.
      programs.mango.package = mango-aspect-threshold;

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
    in {
      imports = [inputs.mango.hmModules.mango];

      wayland.windowManager.mango = {
        enable = true;

        # Same patched package as the system level so the compositor, the mmsg
        # helper and the HM config validation all agree on the config keys.
        package = mango-aspect-threshold;

        # uwsm owns the graphical session and imports the environment into
        # systemd; mango's own mango-session.target would be redundant here.
        systemd.enable = false;

        # Called from mango's exec-once. The HM module wraps this in a bash
        # script and adds `exec-once=~/.config/mango/autostart.sh`.
        autostart_sh = ''
          ${lib.getExe pkgs.tailscale} systray &
          ${lib.getExe' pkgs.udiskie "udiskie"} &
          ${lib.getExe pkgs.wl-clip-persist} --clipboard both &

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

          # Dwindle is the layout on every tag. Split axis follows the focused
          # window's shape (wide: side-by-side, tall: stacked); 1 puts the new
          # window to the right or below, never left, above, or cursor-dependent.
          dwindle_hsplit = 1;
          dwindle_vsplit = 1;

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

          # Overview jump labels: digits first so the first nine windows
          # answer to 1-9, letters after for overflow.
          jump_labels = "123456789ASDFGHJKLQWERTYUIOPZXCVBNM";

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

          # Dwindle everywhere; tag 4 uses the scroller layout, the closest
          # thing to niri's scrolling layout, on both monitors.
          tagrule = [
            "id:*,layout_name:dwindle"
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

              # Overview mode (all tags). Windows are labeled with jump_labels;
              # pressing the bare label key focuses that window and closes the
              # overview. SUPER+digit still switches tags via the binds below.
              "SUPER,O,togglejump"

              # Alt-tab style thumbnail switcher: hold SUPER, tap Tab to cycle,
              # release to land on the selection.
              "SUPER,Tab,switcher,all_tag_next"
              "SUPER+SHIFT,Tab,switcher,all_tag_prev"

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
          # nothing besides Ctrl+Alt+F1-12 is compiled in, so the mouse
          # bindings from the shipped default are restored here. Middle click
          # is deliberately left unbound so it reaches applications (paste,
          # open link in new tab); the shipped default binds it to
          # togglemaximizescreen, which made middle click fullscreen windows.
          mousebind = [
            "SUPER,btn_left,moveresize,curmove"
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
