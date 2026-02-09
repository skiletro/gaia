{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.programs.kitty.enable = lib.mkEnableOption "KiTTy terminal";

  config = lib.mkIf config.erebus.programs.kitty.enable {
    programs.kitty = {
      enable = true;
      settings = {
        hide_window_decorations = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin "titlebar-only";
        enable_audio_bell = false;
        wayland_titlebar_color = "background";
        dynamic_background_opacity = true;
        window_padding_width = 6;
      };
    };
  };
}
