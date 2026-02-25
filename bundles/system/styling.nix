{
  inputs,
  inputs',
  self',
  lib,
  ...
}:
let
  sharedStylixConfig = config: pkgs: {
    base16Scheme = "${self'.packages.base16-schemes}/share/themes/rose-pine.yaml";
    polarity = "dark";
    fonts = {
      sansSerif = {
        package = pkgs.work-sans;
        name = "Work Sans";
      };
      serif = config.stylix.fonts.sansSerif; # Set serif font to the same as the sans-serif
      monospace = {
        package = self'.packages.liga-sf-mono-nerd-font;
        name = "Liga SFMono Nerd Font";
      };
      emoji = {
        package = self'.packages.apple-emoji;
        name = "Apple Color Emoji";
      };

      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 12;
      };
    };
    image =
      let
        wallpaper = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/6o/wallhaven-6o1kyq.png";
          sha256 = "01hm5bqndivyjm9qyxrrxpqdb2s2b5yg37jrmjyznp48ha508nfz";
        };
      in
      pkgs.runCommand "output.png" { }
        "${lib.getExe pkgs.lutgen} apply ${wallpaper} -o $out -- ${builtins.concatStringsSep " " config.lib.stylix.colors.toList}";
  };
in
{
  nixos =
    { config, pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        cursor = {
          package =
            with config.lib.stylix.colors.withHashtag;
            inputs'.cursors.packages.bibata-modern-cursor.override {
              background_color = base00;
              outline_color = base06;
              accent_color = base00;
            };
          name = "Bibata-Modern-Custom";
          size = 24;
        };

        opacity = {
          applications = 0.75;
          popups = 0.75;
          terminal = 0.75;
        };
      }
      // (sharedStylixConfig config pkgs);
    };

  home-manager =
    { pkgs, ... }:
    {
      stylix.icons = {
        enable = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux true;
        package = pkgs.morewaita-icon-theme;
        dark = "MoreWaita";
        light = "MoreWaita";
      };
    };

  darwin =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.darwinModules.stylix ];

      stylix = {
        enable = true;
      }
      // (sharedStylixConfig config pkgs);

      system = {
        activationScripts.postActivation.text =
          # bash
          ''
            printf >&2 '%b' 'Setting \033[0;35mStylix\e[0m wallpaper...\n'
            osascript -e 'tell application "System Events" to tell every desktop to set picture to "${config.stylix.image}" as POSIX file'
          '';

        defaults = {
          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            AppleInterfaceStyleSwitchesAutomatically = false;
            NSStatusItemSpacing = 8; # default=12
            NSStatusItemSelectionPadding = 6; # default=6
            _HIHideMenuBar = false;
            NSAutomaticWindowAnimationsEnabled = false;
          };
          spaces.spans-displays = true;
          dock.expose-group-apps = true;
        };
      };
    };
}
