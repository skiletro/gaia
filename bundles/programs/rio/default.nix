{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rio"] {
  home-manager = {pkgs, ...}: {
    programs.rio = {
      enable = true;
      # Patched to only show the quit confirmation when a foreground process
      # other than the shell is running in any tab or split. Upstream keeps
      # `confirm-before-quit` as a plain boolean (rio issue #1036).
      package = pkgs.rio.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./confirm-quit.patch];
      });
      settings = {
        line-height = 1.2;
        navigation = {
          mode = "Plain";
          use-split = false;
        };

        fonts.symbol-map = let
          mapRange = start: end: family: {
            inherit start end;
            "font-family" = family;
          };
        in [
          # Emoji, coverage verified against the Noto Color Emoji cmap
          (mapRange "2600" "26FF" "Noto Color Emoji")
          (mapRange "2700" "27BF" "Noto Color Emoji")
          (mapRange "1F1E6" "1F1FF" "Noto Color Emoji")
          (mapRange "1F300" "1F5FF" "Noto Color Emoji")
          (mapRange "1F600" "1F64F" "Noto Color Emoji")
          (mapRange "1F680" "1F6FF" "Noto Color Emoji")
          (mapRange "1F900" "1F9FF" "Noto Color Emoji")
          (mapRange "1FA00" "1FAFF" "Noto Color Emoji")

          # Nerd Fonts, ranges from https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
          (mapRange "E000" "E00A" "Symbols Nerd Font Mono") # Pomicons
          (mapRange "E200" "E2A9" "Symbols Nerd Font Mono") # Font Awesome Extension
          (mapRange "E300" "E3E3" "Symbols Nerd Font Mono") # Weather
          (mapRange "E5FA" "E62B" "Symbols Nerd Font Mono") # Seti-UI + Custom
          (mapRange "E700" "E7C5" "Symbols Nerd Font Mono") # Devicons
          (mapRange "EA60" "EBEB" "Symbols Nerd Font Mono") # Codicons
          (mapRange "F000" "F2E0" "Symbols Nerd Font Mono") # Font Awesome
          (mapRange "F300" "F32F" "Symbols Nerd Font Mono") # Font Logos
          (mapRange "F400" "F532" "Symbols Nerd Font Mono") # Octicons
          (mapRange "F0001" "F1AF0" "Symbols Nerd Font Mono") # Material Design Icons
          (mapRange "23FB" "23FE" "Symbols Nerd Font Mono") # IEC Power Symbols
          (mapRange "2500" "259F" "Symbols Nerd Font Mono") # Box Drawing
          (mapRange "276C" "2771" "Symbols Nerd Font Mono") # Heavy Angle Brackets
          (mapRange "E0A0" "E0A3" "Symbols Nerd Font Mono") # Powerline
          (mapRange "E0B0" "E0D4" "Symbols Nerd Font Mono") # Powerline + Extra
        ];
      };
    };

    home.packages = with pkgs; [nerd-fonts.symbols-only];
  };
}
