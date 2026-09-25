{
  home-manager = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      settings = {
        enable_audio_bell = false;
        wayland_title_bar = "background";
        dynamic_background_opacity = true;
        window_padding_width = 6;
        cursor_shape = "beam";
        cursor_trail = 1;
        macos_quit_when_last_window_closed = true;
      };
      extraConfig = ''
        # https://github.com/ryanoasis/gerd-fonts/wiki/Glyph-Sets-and-Code-Points
        symbol_map U+E5FA-U+E62B Symbols Nerd Font Mono
        # Devicons
        symbol_map U+e700-U+e7c5 Symbols Nerd Font Mono
        # Font Awesome
        symbol_map U+f000-U+f2e0 Symbols Nerd Font Mono
        # Font Awesome Extension
        symbol_map U+e200-U+e2a9 Symbols Nerd Font Mono
        # Material Design Icons
        symbol_map U+f0001-U+f1af0 Symbols Nerd Font Mono
        # Weather
        symbol_map U+e300-U+e3e3 Symbols Nerd Font Mono
        # Octicons
        symbol_map U+f400-U+f532 Symbols Nerd Font Mono
        symbol_map U+2665 Symbols Nerd Font Mono
        symbol_map U+26A1 Symbols Nerd Font Mono
        # [Powerline Symbols]
        symbol_map U+e0a0-U+e0a2 Symbols Nerd Font Mono
        symbol_map U+e0b0-U+e0b3 Symbols Nerd Font Mono
        # Powerline Extra Symbols
        symbol_map U+e0b4-U+e0c8 Symbols Nerd Font Mono
        symbol_map U+e0cc-U+e0d4 Symbols Nerd Font Mono
        symbol_map U+e0a3 Symbols Nerd Font Mono
        symbol_map U+e0ca Symbols Nerd Font Mono
        # IEC Power Symbols
        symbol_map U+23fb-U+23fe Symbols Nerd Font Mono
        symbol_map U+2b58 Symbols Nerd Font Mono
        # Font Logos (Formerly Font Linux)
        symbol_map U+f300-U+f32f Symbols Nerd Font Mono
        # Pomicons
        symbol_map U+e000-U+e00a Symbols Nerd Font Mono
        # Codicons
        symbol_map U+ea60-U+ebeb Symbols Nerd Font Mono
        # Heavy Angle Brackets
        symbol_map U+276c-U+2771 Symbols Nerd Font Mono
        # Box Drawing
        symbol_map U+2500-U+259f Symbols Nerd Font Mono
      '';
    };

    home.packages = with pkgs; [nerd-fonts.symbols-only];
  };
}
