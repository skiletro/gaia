{ config, lib, ... }:
{
  options.erebus.services.skhd.enable = lib.mkEnableOption "Simple hotkey daemon for macOS";

  config = lib.mkIf config.erebus.services.skhd.enable {
    services.skhd = {
      enable = true;
      skhdConfig = ''
        cmd - return : open -a Ghostty.app
        cmd + shift - s : screencapture -i -c
      '';
    };
  };
}
