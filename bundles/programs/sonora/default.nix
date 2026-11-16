{inputs, ...}: {
  home-manager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.sonora.homeManagerModules.default];

    programs.sonora = {
      enable = true;
      settings.appearance = {
        theme = "stylix";
        adaptive_theme = false;
      };
    };

    xdg.dataFile."applications/sonora.desktop".source = pkgs.runCommand "sonora.desktop" {} ''
      install -m644 ${config.programs.sonora.package}/share/applications/sonora.desktop $out
      substituteInPlace $out --replace-fail "Icon=sonora" "Icon=juk"
    '';

    # Sonora skips symlinks when discovering themes.
    home.activation.sonoraTheme = let
      theme = (pkgs.formats.json {}).generate "sonora-stylix.json" {
        name = "Stylix";
        author = "jamie";
        version = 1;
        theme = with config.lib.stylix.colors.withHashtag; {
          background = base00;
          foreground = base05;
          border = base02;
          muted = base01;
          muted_foreground = base04;
          secondary = base01;
          secondary_hover = base02;
          secondary_active = base03;
          primary = base0D;
          primary_foreground = base00;
          primary_hover = base0C;
          danger = base08;
          danger_foreground = base00;
          danger_hover = base09;
          popover = base01;
          popover_foreground = base05;
          progress_bar = base0D;
          selection = base0D;
          sidebar = base00;
          sidebar_accent = base01;
          sidebar_border = base02;
          title_bar_border = base02;
          table_head = base01;
          table_head_foreground = base04;
          table_row_border = base02;
          table_hover = base01;
          table_active = base02;
          table_active_border = base0D;
        };
      };
      installTheme = pkgs.writeShellApplication {
        name = "sonora-install-theme";
        runtimeInputs = [pkgs.coreutils pkgs.jq];
        text = ''
          directory=$1
          install -Dm644 ${theme} "$directory/themes/stylix.json"

          # Inline overrides take precedence over the selected theme.
          settings="$directory/settings.json"
          if [[ -f "$settings" ]]; then
            jq 'del(.appearance.theme_overrides)' "$settings" > "$settings.tmp"
            mv "$settings.tmp" "$settings"
          fi
        '';
      };
    in
      lib.hm.dag.entryBetween ["sonoraSettings"] ["writeBoundary"] ''
        run ${lib.getExe installTheme} ${lib.escapeShellArg "${config.xdg.configHome}/sonora"}
      '';
  };
}
