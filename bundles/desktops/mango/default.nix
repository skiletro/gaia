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

  nixos = {
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
      };
    };
  };
}
