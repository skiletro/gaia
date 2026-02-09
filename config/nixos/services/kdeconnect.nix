{ lib, config, ... }:
{
  options.erebus.services.kdeconnect.enable = lib.mkEnableOption "KDE Connect";

  config = lib.mkIf config.erebus.services.kdeconnect.enable {
    programs.kdeconnect.enable = true;
  };
}
