{ config, lib, ... }:
{
  options.erebus.programs.carapace.enable =
    lib.mkEnableOption "carapace, a multi-shell multi-command argument completer";

  config = lib.mkIf config.erebus.programs.carapace.enable {
    programs.carapace.enable = true;
  };
}
