{
  inputs,
  inputs',
  self',
  lib,
  ...
}: let
  sharedStylixConfig = config: pkgs: {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/penumbra-dark-contrast-plus.yaml";
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
    image = let
      wallpaper = pkgs.fetchurl {
        # tags: sky, rain, sunset, clouds
        # src: https://wallhaven.cc/w/e8v9j8
        url = "https://raw.githubusercontent.com/skiletro/wallpapers/7a44be7d7ce96aaa74aaa4814b8fc56d82c9f318/wallhaven-e8v9j8.jpg";
        sha256 = "0ibcf91c0pagj94zx7iw8xcalrcw2cyxba50fr5kcq937pkf2iq1";
      };
    in
      pkgs.runCommand "output.png" {}
      "${lib.getExe pkgs.lutgen} apply ${wallpaper} -o $out -- ${builtins.concatStringsSep " " config.lib.stylix.colors.toList}";
  };
in {
  nixos = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.stylix.nixosModules.stylix];

    stylix =
      {
        enable = true;
        cursor = {
          package = with config.lib.stylix.colors.withHashtag;
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

  home-manager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Stylix ships its KDE config (kdeglobals fonts, cursor theme, color scheme
    # name) as an entry in XDG_CONFIG_DIRS via home-manager's xdg.systemDirs.
    # That variable gets mangled by uwsm, which exports the HM-generated
    # `${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}` suffix as a literal string, so the
    # entry becomes a path that never exists. Qt/KDE apps then fall back to
    # default palettes and fonts and render broken (dark text on dark themes,
    # wrong typeface). Copy the files into ~/.config, which always takes
    # precedence over XDG_CONFIG_DIRS.
    stylixKdeConfig =
      lib.findFirst
      (dir: lib.hasSuffix "stylix-kde-config" dir)
      null
      config.xdg.systemDirs.config;
  in {
    stylix.icons = {
      enable = true;
      package = pkgs.whitesur-icon-theme.override {
        alternativeIcons = true;
        boldPanelIcons = true;
      };
      dark = "WhiteSur-dark";
      light = "WhiteSur-light";
    };

    home.pointerCursor.enable = true;

    # KF6 apps read the icon theme from kdeglobals [Icons] and ignore qt6ct's
    # setting, falling back to Breeze when it is missing. Stylix does not write
    # an [Icons] section, so append one derived from stylix's icon theme.
    xdg.configFile = lib.mkIf (stylixKdeConfig != null) {
      "kdeglobals".text =
        builtins.readFile "${stylixKdeConfig}/kdeglobals"
        + "\n[Icons]\nTheme=${config.stylix.icons.dark}\n";
      "kcminputrc".source = "${stylixKdeConfig}/kcminputrc";
      "kded5rc".source = "${stylixKdeConfig}/kded5rc";
    };
  };
}
