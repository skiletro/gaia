{
  lib,
  inputs,
  inputs',
  ...
}: let
  package = inputs'.mango.packages.mango.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ (lib.filter
        (p: lib.strings.hasSuffix ".patch" p)
        (lib.filesystem.listFilesRecursive ./patches));
    postInstall = ''
      rm -f $out/share/wayland-sessions/mango.desktop
    '';
  });
in {
  requires = [
    "programs.rio"
    "programs.suite"
    "programs.vicinae"
    "services.noctalia"
  ];

  nixos = {pkgs, ...}: {
    imports = [inputs.mango.nixosModules.mango];

    programs.mango = {
      enable = true;
      addLoginEntry = false;
      inherit package;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors.mango = {
        prettyName = "mango";
        comment = "Mango (uwsm-managed)";
        binPath = "/run/current-system/sw/bin/mango";
      };
    };

    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
    };

    security.polkit.enable = true;

    xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings.screencast = {
          chooser_type = "simple";
          chooser_cmd = lib.getExe' pkgs.wlr-utils "wlr-chooser";
        };
      };
      xdgOpenUsePortal = false;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config = {
        common = {
          # Defaults https://mangowm.github.io/docs/configuration/xdg-portals
          default = ["gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };
    };
  };

  home-manager = {pkgs, ...}: {
    imports = [inputs.mango.hmModules.mango];

    services.udiskie = {
      enable = true;
      settings.program_options.file_manager = lib.getExe pkgs.nautilus;
    };

    systemd.user.services.wl-clip-persist = {
      Unit = {
        Description = "Persist Wayland clipboard contents";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard both";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    wayland.windowManager.mango = {
      enable = true;
      inherit package;
      systemd.enable = false; # use uwsm instead

      settings = {
        # Behaviour
        focus_on_activate = 1;
        sloppy_focus = 1; # focus-follows-mouse
        tag_carousel = 1;
        warp_cursor = 0;
        auto_reload_config = 1;

        # Input
        xkb_rules_layout = "gb";
        xkb_rules_options = "ctrl:nocaps";

        mouse_accel_profile = 1; # flat
        mouse_accel_speed = 0.6;

        # Trackpad
        trackpad_accel_profile = 2;
        trackpad_accel_speed = 0.1;
        trackpad_natural_scrolling = 1;
        trackpad_disable_while_typing = 1;
        trackpad_click_method = 2;
        trackpad_scroll_factor = 1.1;
        tap_and_drag = 1;

        # Cursor
        cursor_hide_on_keypress = 1; # hide-when-typing
        disable_middle_paste = 1;

        # Dwindle is the layout on every tag. Split axis follows the focused
        # window's shape (wide: side-by-side, tall: stacked); 1 puts the new
        # window to the right or below, never left, above, or cursor-dependent.
        dwindle_horizontal_split = 1;
        dwindle_vertical_split = 1;

        # Overview jump labels: digits first so the first nine windows
        # answer to 1-9, letters after for overflow.
        jump_labels = "123456789RUTYEIWOQPGHFKDLS";

        # Scroller is the closest thing to niri's scrolling layout.
        scroller_structs = 20;
        scroller_default_proportion = 0.5;
        scroller_default_proportion_single = 0.5;
        scroller_ignore_proportion_single = 0;
        scroller_focus_center = 0;
        scroller_prefer_center = 0;
        scroller_prefer_overspread = 0;
        scroller_proportion_preset = "0.5,0.8,1.0";

        # Environment
        env = ["NIXOS_OZONE_WL,1"];

        # Dwindle everywhere; tag 4 uses the scroller layout, the closest
        # thing to niri's scrolling layout, on both monitors.
        tag_rule = [
          "id:*,layout_name:dwindle"
        ];

        window_rule = [
          # Noctalia settings window
          "is_floating:1,width:1080,height:920,app_id:dev.noctalia.Noctalia"

          # Steam notification toasts, bottom-right
          "is_floating:1,offset_x:25,offset_y:25,title:^notificationtoasts_\\d+_desktop$,app_id:steam"

          # Portals
          "is_floating:1,app_id:org\\.freedesktop\\.impl\\.portal\\.desktop\\.gnome"
          "is_floating:1,app_id:xdg-desktop-portal-gtk"

          # File dialogs
          "is_floating:1,title:^(Open File)(.*)$"
          "is_floating:1,title:^(Select a File)(.*)$"
          "is_floating:1,title:^(Open Folder)(.*)$"
          "is_floating:1,title:^(Save As)(.*)$"
          "is_floating:1,title:^(Library)(.*)$"
          "is_floating:1,title:^(File Upload)(.*)$"
          "is_floating:1,title:^(.*)(wants to save)$"
          "is_floating:1,title:^(.*)(wants to open)$"

          # Apps
          "is_floating:1,app_id:crashreporter"
          "is_floating:1,app_id:org\\.gnome\\.FileRoller"
          "is_floating:1,app_id:org\\.gnome\\.NautilusPreviewer"
          "is_floating:1,app_id:Emulator"
        ];
      };
    };
  };
}
