{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.programs.vial.enable = lib.mkEnableOption "Vial";

  config = lib.mkIf config.erebus.programs.vial.enable {
    environment.systemPackages = [ pkgs.vial ];

    services.udev.packages = with pkgs; [
      vial
      via
    ];
  };
}
