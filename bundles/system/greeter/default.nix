{
  lib,
  inputs',
  config,
  ...
}: let
  desktop = config.gaia.desktop;
in {
  nixos = {config, ...}: let
    sessionData = config.services.displayManager.sessionData.desktops;
    sessionPaths = lib.concatStringsSep ":" [
      "${sessionData}/share/xsessions"
      "${sessionData}/share/wayland-sessions"
    ];

    # tuigreet's --remember-user-session stores the .desktop path, which is a
    # different nix store path on every update, so the remembered session
    # never matches and it falls back to the first entry (the plain, non-uwsm
    # session). --cmd sets the session to run when nothing matched, keeping
    # the uwsm session the default after updates.
    defaultSessionArg =
      lib.optional (desktop != null)
      "--cmd '${lib.getExe config.programs.uwsm.package} start -- ${desktop}-uwsm.desktop'";
  in {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " ([
              (lib.getExe inputs'.tuigreet.packages.tuigreet)
              "--time"
              "--remember"
              "--remember-user-session"
              "--asterisks"

              # The VT console only supports 16 colours, so hex (truecolor)
              # escapes are ignored. Named colours render on any console; a
              # black-on-black border is invisible.
              "--theme 'border=black;container=black;title=white'"

              "--sessions '${sessionPaths}'"
            ]
            ++ defaultSessionArg);
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
