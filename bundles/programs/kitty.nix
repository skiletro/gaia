{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "kitty" ] {

  home-manager = {
    programs.kitty = {
      enable = true;
      settings = {
        hide_window_decorations = "titlebar-only";
        enable_audio_bell = false;
        wayland_title_bar = "background";
        dynamic_background_opacity = true;
        window_padding_width = 6;
      };
    };
  };

}
