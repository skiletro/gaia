{inputs, ...}: {
  home-manager = {config, ...}: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    imports = [inputs.sonora.homeManagerModules.default];

    programs.sonora = {
      enable = true;
      settings.appearance = {
        theme = "dark";
        theme_overrides = with colors; {
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
    };
  };
}
