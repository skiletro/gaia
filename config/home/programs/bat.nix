{
  lib,
  config,
  ...
}:
{
  options.erebus.programs.bat.enable = lib.mkEnableOption "Bat, the cat clone with wings";

  config = lib.mkIf config.erebus.programs.bat.enable {
    programs.bat.enable = true;
    programs.fish.shellAbbrs.cat = "bat";
  };
}
