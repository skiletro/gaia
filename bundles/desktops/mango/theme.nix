{
  home-manager = {config, ...}: let
    withAlpha = alpha: color: "0x${color}${alpha}";
    opaque = withAlpha "ff";
  in
    with config.lib.stylix.colors; {
      # wlr-chooser reads colours and fonts from theme.toml. Screens are
      # outlined in screen-accent and windows in window-accent so the two
      # cannot be confused; backdrop dims the desktop behind the card.
      xdg.configFile."wlr-chooser/theme.toml".text =
        # toml
        ''
          backdrop      = "#${base00}cc"
          bg            = "#${base00}"
          card          = "#${base01}"
          tile          = "#${base01}"
          tile-hover    = "#${base02}"
          tile-selected = "#${base03}"
          thumb         = "#${base00}"
          text          = "#${base05}"
          text-dim      = "#${base04}"
          accent        = "#${base0D}"
          screen-accent = "#${base0C}"
          window-accent = "#${base0E}"

          font      = "${config.stylix.fonts.monospace.name}"
          font-size = ${toString config.stylix.fonts.sizes.applications}
        '';

      wayland.windowManager.mango.settings = {
        # Appearance / layout
        gap_inner_horizontal = 6;
        gap_inner_vertical = 6;
        gap_outer_horizontal = 6;
        gap_outer_vertical = 6;
        border_px = 2;
        border_radius = config.stylix.borderRadius;
        root_color = "0x00000000"; # transparent background (noctalia draws it)

        focus_color = opaque base0D;
        border_color = opaque base03;
        urgent_color = opaque base08;
        drop_color = withAlpha "55" base0D;
        split_color = opaque base09;
        maximized_screen_color = opaque base0B;
        scratchpad_color = opaque base0C;
        global_color = opaque base0A;
        overlay_color = opaque base0E;
        shadows_color = opaque base00;

        # Overview jump labels
        jump_label_decorate_bg_color = opaque base01;
        jump_label_decorate_border_color = opaque base0D;
        jump_label_decorate_fg_color = opaque base05;
        jump_label_decorate_focus_bg_color = opaque base0D;
        jump_label_decorate_focus_fg_color = opaque base00;

        # monocle group bar
        group_bar_decorate_bg_color = opaque base01;
        group_bar_decorate_border_color = opaque base0D;
        group_bar_decorate_fg_color = opaque base05;
        group_bar_decorate_focus_bg_color = opaque base0D;
        group_bar_decorate_focus_fg_color = opaque base00;

        # Blur
        blur = 0;
        blur_layer = 0;

        # Window shadows (Noctalia draws its own layer shadows)
        shadows = 1;
        layer_shadows = 0;
        shadow_only_floating = 0;
        shadows_size = 4;
        shadows_blur = 12;
        shadows_position_x = 2;
        shadows_position_y = 2;

        # Animations. Tag switches animate vertically.
        animations = 1;
        layer_animations = 0;
        tag_animation_direction = 0;
        animation_type_open = "slide";
        animation_type_close = "slide";
        animation_duration_open = 250;
        animation_duration_close = 200;
        animation_duration_move = 250;
        animation_duration_tag = 250;
        animation_curve_open = "0.46,1.0,0.29,1";
        animation_curve_move = "0.46,1.0,0.29,1";
        animation_curve_tag = "0.46,1.0,0.29,1";
        animation_curve_close = "0.08,0.92,0,1";
        animation_curve_focus = "0.46,1.0,0.29,1";
        animation_curve_opacity_fade_out = "0.5,0.5,0.5,0.5";
        animation_curve_opacity_fade_in = "0.46,1.0,0.29,1";
      };
    };
}
