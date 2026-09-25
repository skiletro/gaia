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
        terminal = 13;
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
    colors = config.lib.stylix.colors;

    # Stylix ships its KDE config (kdeglobals fonts, cursor theme, color scheme
    # name) as an entry in XDG_CONFIG_DIRS via home-manager's xdg.systemDirs.
    # That variable gets mangled by uwsm, which exports the HM-generated
    # `${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}` suffix as a literal string, so the
    # entry becomes a path that never exists. Qt/KDE apps then fall back to
    # default palettes and fonts and render broken (dark text on dark themes,
    # wrong typeface). Copy the files into ~/.config, which always takes
    # precedence over XDG_CONFIG_DIRS.
    #
    # NOTE: the mangled variable is still exported by the session (check with
    # `echo $XDG_CONFIG_DIRS`); the copies below are why nothing breaks.
    stylixKdeConfig =
      lib.findFirst
      (dir: lib.hasSuffix "stylix-kde-config" dir)
      null
      config.xdg.systemDirs.config;

    # Stylix's color scheme file (the KColorScheme .colors with the actual
    # [Colors:*] values) only ships inside its look-and-feel theme package,
    # which is applied exclusively by plasma-apply-lookandfeel. Outside a
    # Plasma session that never runs, so apps that take their palette from
    # KColorScheme (anything Kirigami/QML-based: kdeconnect, wivrn-dashboard,
    # ...) fall back to a hardcoded light palette. Replicate stylix's scheme
    # generation here (verbatim from modules/kde/hm.nix) and deploy it to
    # ~/.local/share/color-schemes. Everything derives from
    # config.lib.stylix.colors, so swapping the stylix scheme regenerates the
    # file with a matching name automatically.
    colorschemeSlug =
      lib.concatStrings
      (lib.filter lib.isString (builtins.split "[^a-zA-Z]" colors.scheme));

    colorEffect = {
      ColorEffect = 0;
      ColorAmount = 0;
      ContrastEffect = 1;
      ContrastAmount = 0.5;
      IntensityEffect = 0;
      IntensityAmount = 0;
    };

    mkColorTriple = name:
      lib.concatStringsSep ","
      (map (color: colors."${name}-rgb-${color}") [
        "r"
        "g"
        "b"
      ]);

    mkColorMapping = num: let
      hex = "base0${lib.toHexString num}";
    in {
      name = hex;
      value = mkColorTriple hex;
    };

    colors' = builtins.listToAttrs (map mkColorMapping (lib.range 0 15));

    kdecolors = with colors'; {
      BackgroundNormal = base00;
      BackgroundAlternate = base01;
      DecorationFocus = base0D;
      DecorationHover = base0D;
      ForegroundNormal = base05;
      ForegroundActive = base05;
      ForegroundInactive = base05;
      ForegroundLink = base05;
      ForegroundVisited = base05;
      ForegroundNegative = base08;
      ForegroundNeutral = base0D;
      ForegroundPositive = base0B;
    };

    colorscheme = {
      General = {
        ColorScheme = colorschemeSlug;
        Name = colors.scheme;
      };

      "ColorEffects:Disabled" = colorEffect;
      "ColorEffects:Inactive" = colorEffect;

      "Colors:Window" = kdecolors;
      "Colors:View" = kdecolors;
      "Colors:Button" = kdecolors;
      "Colors:Tooltip" = kdecolors;
      "Colors:Complementary" = kdecolors;
      "Colors:Selection" =
        kdecolors
        // (with colors'; {
          BackgroundNormal = base0D;
          BackgroundAlternate = base0D;
          ForegroundNormal = base00;
          ForegroundActive = base00;
          ForegroundInactive = base00;
          ForegroundLink = base00;
          ForegroundVisited = base00;
        });

      WM = with colors'; {
        activeBlend = base0A;
        activeBackground = base00;
        activeForeground = base05;
        inactiveBlend = base03;
        inactiveBackground = base00;
        inactiveForeground = base05;
      };
    };

    # Stylix's INI formatter (modules/kde/hm.nix).
    formatValue = value:
      if lib.isBool value
      then
        if value
        then "true"
        else "false"
      else toString value;

    formatSection = path: data: let
      header = lib.concatStrings (map (p: "[${p}]") path);
      formatChild = name: formatLines (path ++ [name]);
      children = lib.mapAttrsToList formatChild data;
      partitioned = lib.partition lib.isString children;
      directChildren = partitioned.right;
      indirectChildren = partitioned.wrong;
    in
      lib.optional (directChildren != []) header
      ++ directChildren
      ++ lib.flatten indirectChildren;

    formatLines = path: data:
      if lib.isAttrs data
      then
        if data ? _immutable
        then
          if lib.isAttrs data.value
          then formatSection (path ++ ["$i"]) data.value
          else "${lib.last path}[$i]=${formatValue data.value}"
        else formatSection path data
      else "${lib.last path}=${formatValue data}";

    formatConfig = data: lib.concatStringsSep "\n" (formatLines [] data);
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

    # Use KDE's Qt platform theme instead of qt6ct. qt6ct has no palette
    # integration (stylix enables `custom_palette` without writing any
    # palette data, and since Qt 6.9 QT_STYLE_OVERRIDE no longer works), so
    # Kirigami/QML apps get Qt's default light palette. The KDE platform
    # theme (kdePackages.plasma-integration, below) feeds kdeglobals and the
    # color scheme file to every Qt app at the QPA level.
    stylix.targets.qt.platform = "kde";

    # Stylix switches its recommended Qt style to breeze on the kde platform,
    # but breeze (the style plugin) is not installed. Stay on kvantum so the
    # Base16Kvantum theme keeps being generated and widget apps like dolphin
    # keep their current dark look.
    qt.style.name = lib.mkForce "kvantum";

    home.pointerCursor.enable = true;

    home.packages = [pkgs.kdePackages.plasma-integration];

    # KF6 apps read the icon theme from kdeglobals [Icons] and ignore qt6ct's
    # setting, falling back to Breeze when it is missing. Stylix does not write
    # an [Icons] section, so append one derived from stylix's icon theme.
    # widgetStyle is read by the KDE platform theme and KStyleManager to pick
    # the widget style; keep it on kvantum for the same reason as above.
    # Some apps (kdeconnect's KCM) take their palette from the [Colors:*]
    # groups embedded in kdeglobals itself instead of resolving the color
    # scheme file by name, so append the scheme values here as well.
    xdg.configFile = lib.mkIf (stylixKdeConfig != null) {
      "kdeglobals".text =
        builtins.readFile "${stylixKdeConfig}/kdeglobals"
        + "\n[Icons]\nTheme=${config.stylix.icons.dark}\n"
        + "\n[KDE]\nwidgetStyle=kvantum\n"
        + "\n"
        + formatConfig colorscheme
        + "\n";
      "kcminputrc".source = "${stylixKdeConfig}/kcminputrc";
      "kded5rc".source = "${stylixKdeConfig}/kded5rc";
    };

    xdg.dataFile."color-schemes/${colorschemeSlug}.colors".text =
      formatConfig colorscheme;
  };
}
