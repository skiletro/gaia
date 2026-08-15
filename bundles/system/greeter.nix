{
  bundleLib,
  lib,
  inputs',
  ...
}:
bundleLib.mkEnableModule ["gaia" "system" "greeter"] {
  nixos = {config, ...}: let
    sessionData = config.services.displayManager.sessionData.desktops;
    sessionPaths = lib.concatStringsSep ":" [
      "${sessionData}/share/xsessions"
      "${sessionData}/share/wayland-sessions"
    ];
  in {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            (lib.getExe inputs'.tuigreet.packages.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"

            "--sessions '${sessionPaths}'"
          ];
        };
      };
    };

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
