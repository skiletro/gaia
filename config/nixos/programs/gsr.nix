{
  lib,
  config,
  self,
  ...
}:
{
  imports = [ self.nixosModules.gsr ];

  options.erebus.programs.gsr.enable =
    lib.mkEnableOption "gpu-screen-recorder & it's shadowplay inspired UI";

  config = lib.mkIf config.erebus.programs.gsr.enable {
    programs.gpu-screen-recorder-ui.enable = true;
  };
}
