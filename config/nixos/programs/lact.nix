{ config, lib, ... }:
{
  options.erebus.programs.lact.enable = lib.mkEnableOption "LACT";

  config = lib.mkIf config.erebus.programs.lact.enable {
    services.lact = {
      enable = true;
      # settings = {};
    };
  };
}
