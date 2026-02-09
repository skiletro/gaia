{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.services.raycast.enable = lib.mkEnableOption "Raycast";

  config = lib.mkIf config.erebus.services.raycast.enable {
    environment.systemPackages = [ pkgs.raycast ];
  };
}
