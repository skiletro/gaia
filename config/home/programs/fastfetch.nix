{
  config,
  lib,
  ...
}:
{
  options.erebus.programs.fastfetch.enable = lib.mkEnableOption "Fastfetch";

  config = lib.mkIf config.erebus.programs.fastfetch.enable {
    programs.fastfetch = {
      enable = true;
    };
  };
}
