{ config, lib, ... }:
{
  options.erebus.programs.broot.enable = lib.mkEnableOption "Broot";

  config = lib.mkIf config.erebus.programs.broot.enable {
    programs.broot.enable = true;
  };
}
