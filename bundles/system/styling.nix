{
  inputs,
  inputs',
  self',
  lib,
  ...
}:
let
  sharedStylixConfig = config: pkgs: {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    polarity = "dark";
    fonts = {
      sansSerif = {
        package = self'.packages.space-grotesk;
        name = "Space Grotesk";
      };
      serif = config.stylix.fonts.sansSerif; # Set serif font to the same as the sans-serif
      monospace = {
        package = self'.packages.pragmata-pro;
        name = "PragmataPro Mono Liga";
      };
      emoji = {
        package = self'.packages.apple-emoji;
        name = "Apple Color Emoji";
      };

      sizes = {
        applications = 10;
        desktop = 10;
        popups = 10;
        terminal = 14;
      };
    };
    image =
      let
        wallpaper = pkgs.fetchurl {
          # tags: macro, plants, nature, depth of field
          url = "https://w.wallhaven.cc/full/8o/wallhaven-8o8owk.png";
          sha256 = "1cynpqlsid9fsvdcr834ppmq2672wls5incnx9l5arzfi765clrm";
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
            inputs'.cursors.packages.apple-cursor.override {
              background_color = base00;
              outline_color = base06;
              accent_color = base00;
            };
          name = "Apple-Custom";
          size = 24;
        };

        opacity = {
          applications = 0.85;
          popups = 0.85;
          terminal = 0.85;
        };
      }
      // (sharedStylixConfig config pkgs);
    };

  home-manager =
    { pkgs, ... }:
    {
      stylix.icons = {
        enable = true;
        package = pkgs.morewaita-icon-theme;
        dark = "MoreWaita";
        light = "MoreWaita";
      };

      home.pointerCursor.enable = true;
    };
}
