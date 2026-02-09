{
  self,
  lib,
  config,
  ...
}:
{
  options.erebus.services.protondrive.enable = lib.mkEnableOption "Rclone Proton Drive Sync";

  imports = [ self.nixosModules.protondrive ];

  config = lib.mkIf config.erebus.services.protondrive.enable {
    sops.secrets."rclone-protondrive".owner = "jamie";

    services.protondrive = {
      enable = true;
      passwordPath = config.sops.secrets.rclone-protondrive.path;
    };
  };
}
