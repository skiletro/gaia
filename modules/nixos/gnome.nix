{
  lib,
  config,
  pkgs,
  pkgs',
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types)
    listOf
    package
    str
    attrs
    ;
  cfg = config.services.desktopManager.gnome;
in
{
  options.services.desktopManager.gnome = {
    extensions = mkOption {
      type = listOf package;
      default = [ ];
    };
    thumbnailers = mkOption {
      type = listOf package;
      default = [ ];
    };

    settings = {
      pinned-apps = lib.mkOption {
        type = listOf str;
        default = [ ];
      };
      custom-keybindings = lib.mkOption {
        type = listOf attrs;
        default = [ ];
      };
    };

    dconf-settings = lib.mkOption {
      type = attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      cfg.extensions
      ++ cfg.thumbnailers
      ++ (with pkgs; [
        # keep-sorted start
        adwaita-icon-theme # fixes some missing icons
        adwaita-icon-theme-legacy # fixes some missing icons
        file-roller
        gapless
        gjs # fixes ding ext
        libheif
        libheif.out # HEIC Image Previews
        mission-center # Task Manager
        papers # Pdf viewer
        showtime # Video Player
        smile # Emoji picker
        # keep-sorted end
      ]);

    environment.gnome.excludePackages = with pkgs; [
      # keep-sorted start
      epiphany
      evince
      geary
      gnome-connections
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-software
      gnome-tour
      orca
      seahorse
      simple-scan
      totem
      # keep-sorted end
    ];

    environment.pathsToLink = mkIf (cfg.thumbnailers != [ ]) [
      "share/thumbnailers"
    ];

    # Fixes
    services.udev.packages = [ pkgs.gnome-settings-daemon ];

    nixpkgs.overlays = [
      (_final: prev: {
        nautilus = prev.nautilus.overrideAttrs (nprev: {
          buildInputs =
            nprev.buildInputs
            ++ (with pkgs.gst_all_1; [
              gst-plugins-good
              gst-plugins-bad
            ]);
        });
      })
    ];

    home-manager.sharedModules = lib.singleton (userAttrs: {
      dconf = {
        enable = lib.mkDefault true;
        settings =
          let
            mkCustomKeybindings = lib.listToAttrs (
              lib.imap0 (i: value: {
                name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}";
                inherit value;
              }) cfg.settings.custom-keybindings
            );
          in
          lib.mkMerge [
            {
              "org/gnome/shell" = {
                disable-user-extensions = false;
                enabled-extensions =
                  map (ext: ext.extensionUuid) cfg.extensions
                  ++ lib.optional config.stylix.enable "user-theme@gnome-shell-extensions.gcampax.github.com";
              };

              "org/gnome/shell".favorite-apps = cfg.settings.pinned-apps;

              "org/gnome/settings-daemon/plugins/media-keys" = {
                custom-keybindings = lib.pipe (lib.attrNames mkCustomKeybindings) [
                  (map (x: "/${x}/"))
                ];
              };

              "org/gnome/shell/extensions/search-light" =
                with config.lib.stylix.colors;
                let
                  mkColor =
                    r: g: b:
                    lib.gvariant.mkTuple (
                      map builtins.fromJSON [
                        r
                        g
                        b
                      ]
                      ++ [ 1.0 ]
                    );
                in
                lib.mkIf config.stylix.enable {
                  "border-radius" = 1.1;
                  "background-color" = mkColor base00-dec-r base00-dec-g base00-dec-b;
                  "text-color" = mkColor base05-dec-r base05-dec-g base05-dec-b;
                  "border-color" = mkColor base01-dec-r base01-dec-g base01-dec-b;
                  "border-thickness" = 1;
                  "scale-width" = 0.17;
                  "scale-height" = 0.2;
                };

              "org/gnome/shell/extensions/dash-to-dock" = lib.mkIf config.stylix.enable {
                apply-custom-theme = false;
                custom-theme-shrink = false;
                background-color =
                  with config.lib.stylix.colors;
                  "rgb(${base00-dec-r},${base00-dec-g},${base00-dec-g})";
                background-opacity = 0.8;
                custom-background-color = false;
                transparency-mode = "DEFAULT";
              };
            }
            mkCustomKeybindings
            cfg.dconf-settings
          ];
      };

      home.activation.gnome-steam-shortcut-fixer = mkIf config.erebus.programs.steam.enable (
        userAttrs.lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
          ''
            run ${lib.getExe pkgs'.gnome-steam-shortcut-fixer} -f
          ''
      );
    });
  };
}
