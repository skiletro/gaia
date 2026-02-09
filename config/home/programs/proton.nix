{
  lib,
  config,
  pkgs,
  pkgs',
  ...
}:
{
  options.erebus.programs.proton.enable =
    lib.mkEnableOption "Proton suite of apps: Proton Mail, Proton Pass, etc.";

  config = lib.mkIf config.erebus.programs.proton.enable {
    home.packages = [
      pkgs.protonmail-desktop
      pkgs'.protonvpn-bin
      pkgs'.protonpass-bin
    ];
  };
}
