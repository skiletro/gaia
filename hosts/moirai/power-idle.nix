{
  home-manager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    idleOverride = "${config.xdg.configHome}/noctalia/zz-power-idle.toml";
    batteryIdle = (pkgs.formats.toml {}).generate "noctalia-battery-idle.toml" {
      idle.behavior = {
        lock.timeout = 300.0;
        screen-off.timeout = 360.0;
        lock-and-suspend = {
          enabled = true;
          timeout = 900.0;
        };
      };
    };
    powerIdle = pkgs.writeShellScript "noctalia-power-idle" ''
      set -euo pipefail

      idle_override=${lib.escapeShellArg idleOverride}

      apply_idle() {
        local on_battery
        on_battery="$(${lib.getExe' pkgs.systemd "busctl"} --system get-property \
          org.freedesktop.UPower /org/freedesktop/UPower \
          org.freedesktop.UPower OnBattery)"
        if [ "$on_battery" = "b true" ]; then
          if ! ${lib.getExe' pkgs.diffutils "cmp"} -s ${batteryIdle} "$idle_override"; then
            ${lib.getExe' pkgs.coreutils "mkdir"} -p ${lib.escapeShellArg "${config.xdg.configHome}/noctalia"}
            ${lib.getExe' pkgs.coreutils "install"} -m 600 ${batteryIdle} "$idle_override.tmp"
            ${lib.getExe' pkgs.coreutils "mv"} -f "$idle_override.tmp" "$idle_override"
          fi
        else
          ${lib.getExe' pkgs.coreutils "rm"} -f "$idle_override"
        fi
      }

      if [ "''${1:-}" = "--once" ]; then
        apply_idle
        exit 0
      fi

      ${lib.getExe pkgs.upower} --monitor | {
        apply_idle
        while read -r _; do
          apply_idle
        done
      }
    '';
  in {
    systemd.user.services.noctalia-power-idle = lib.mkIf config.programs.noctalia.enable {
      Unit = {
        Description = "Use shorter Noctalia idle timeouts on battery";
        After = ["graphical-session.target"];
        Before = ["noctalia.service"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${powerIdle} --once";
        ExecStart = "${powerIdle}";
        ExecStopPost = "${lib.getExe' pkgs.coreutils "rm"} -f ${lib.escapeShellArg idleOverride} ${lib.escapeShellArg "${idleOverride}.tmp"}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
