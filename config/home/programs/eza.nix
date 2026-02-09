{
  lib,
  config,
  ...
}:
{
  options.erebus.programs.eza.enable = lib.mkEnableOption "eza, the `ls` replacement";

  config = lib.mkIf config.erebus.programs.eza.enable {
    programs.eza = {
      enable = true;
      icons = "auto";
    };
  };
}
