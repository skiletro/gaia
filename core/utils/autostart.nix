{
  config,
  lib,
  ...
}: {
  options.gaia.autoStart = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
  };

  config.home-manager = {pkgs, ...}: let
    mkDesktopName = command: lib.baseNameOf (lib.head (lib.splitString " " command));

    mkAutoStartEntry = command: (
      (pkgs.makeDesktopItem {
        desktopName = mkDesktopName command;
        name = mkDesktopName command;
        exec = command;
        noDisplay = true;
        destination = "/";
      })
      + /${mkDesktopName command}.desktop
    );
  in {
    xdg.autostart = lib.mkIf (config.gaia.autoStart != []) {
      enable = true;
      readOnly = true;
      entries = map mkAutoStartEntry config.gaia.autoStart;
    };
  };
}
