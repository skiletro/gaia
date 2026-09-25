{
  lib,
  inputs',
  config,
  ...
}: let
  select = import ../../../lib/desktop-selection.nix {inherit lib;};
  desktop = select.default config.gaia.desktops;
in {
  nixos = {config, ...}: let
    sessionData = config.services.displayManager.sessionData.desktops;
    sessionPaths = lib.concatStringsSep ":" [
      "${sessionData}/share/xsessions"
      "${sessionData}/share/wayland-sessions"
    ];

    # tuigreet remembers .desktop paths in the Nix store, which change after
    # rebuilds. With one enabled desktop, --cmd keeps its UWSM entry as fallback.
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
