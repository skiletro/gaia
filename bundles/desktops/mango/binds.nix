{lib, ...}: {
  home-manager = {pkgs, ...}: {
    wayland.windowManager.mango.settings = {
      bind =
        [
          # Apps
          "SUPER,Return,spawn,rio"
          "SUPER,Space,spawn,vicinae toggle"
          "NONE,XF86Search,spawn,vicinae toggle"
          "SUPER,F,spawn,helium"
          "SUPER,E,spawn,nautilus --new-window"
          "SUPER,P,spawn,vicinae deeplink vicinae://launch/@leonkohli/vicinae-extension-process-manager-0/processes"
          "SUPER+SHIFT,P,spawn,vicinae deeplink vicinae://launch/power"
          "SUPER,Period,spawn,vicinae deeplink vicinae://launch/core/search-emojis"
          "SUPER+SHIFT,BackSpace,spawn,noctalia msg session lock"
          "SUPER+SHIFT,S,spawn,noctalia msg screenshot-region"
          "SUPER,Z,spawn,gsr-ui-cli toggle-show"

          # Forward delete on keyboards without a dedicated Delete key
          "SUPER,BackSpace,spawn,${lib.getExe pkgs.wtype} -k Delete"

          # Window management
          "SUPER+SHIFT,Q,killclient"
          "SUPER+SHIFT,F,togglemaximizescreen"
          "SUPER+CTRL+SHIFT,F,togglefullscreen"
          "SUPER+SHIFT,Space,togglefloating"
          "SUPER+SHIFT,G,spawn,${(
            pkgs.writers.writeNu "mango-toggle-global" ''
              let client = (mmsg get focusing-client | from json)
              if ($client.id? | is-empty) {
                exit 0
              }

              # Floating should match the new pin state after toggling global.
              if $client.is_floating == $client.is_global {
                mmsg dispatch togglefloating $"client,($client.id)"
              }
              exec mmsg dispatch toggleglobal $"client,($client.id)"
            ''
          )}"
          "SUPER,O,togglejump"
          ''SUPER,M,spawn,mmsg dispatch setlayout,$(echo -e 'dwindle\ngrid\nscroller' | vicinae dmenu -p 'Pick a layout...')''

          # Alt-tab style thumbnail switcher
          "SUPER,Tab,switcher,all_tag_next"
          "SUPER+SHIFT,Tab,switcher,all_tag_prev"

          # Resize window
          "SUPER,Minus,resizewin,-60,0"
          "SUPER,Equal,resizewin,+60,0"
          "SUPER+SHIFT,Minus,resizewin,0,-60"
          "SUPER+SHIFT,Equal,resizewin,0,+60"

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

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
        # Trackpad-friendly resize fallback: hold Super+Shift and drag with
        # the primary click when right-click dragging is awkward.
        "SUPER+SHIFT,btn_left,moveresize,curresize"
      ];

      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
      ];

      gesturebind = [
        "none,up,3,viewnext_have_client"
        "none,down,3,viewprev_have_client"
        "none,up,4,enteroverview"
        "none,down,4,leaveoverview"
      ];
    };
  };
}
