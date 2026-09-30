{
  lib,
  pkgs,
  config,
  ...
}: let
  powerBlur = pkgs.writeShellScript "mango-power-blur" ''
    power_blur="$HOME/.config/mango/power.conf"

    set -o pipefail

    upower=${lib.getExe pkgs.upower}
    mmsg=${lib.getExe' config.wayland.windowManager.mango.package "mmsg"}
    grep=${lib.getExe pkgs.gnugrep}

    if ! "$upower" -e | "$grep" -q '/battery_'; then
      if [ -f "$power_blur" ]; then
        rm -f "$power_blur"
        "$mmsg" dispatch reload_config
      fi
      exit 0
    fi

    on_ac_power() {
      local device
      local line_power=0

      while read -r device; do
        case "$device" in
          */line_power_*)
            line_power=1
            if "$upower" -i "$device" | "$grep" -q '^ *online: *yes$'; then
              return 0
            fi
            ;;
        esac
      done < <("$upower" -e)

      # If UPower exposes no line-power device, leave blur enabled.
      [ "$line_power" -eq 0 ]
    }

    apply_blur() {
      local enabled
      local optimized
      local desired
      local current

      if on_ac_power; then
        enabled=1
        optimized=0
      else
        enabled=0
        optimized=1

      fi

      desired="blur=$enabled
    blur_layer=$enabled
    blur_optimized=$optimized"
      current=""
      if [ -f "$power_blur" ]; then
        current="$(<"$power_blur")"
      fi
      if [ "$current" = "$desired" ]; then
        return
      fi

      printf '%s\n' "$desired" > "$power_blur"
      "$mmsg" dispatch reload_config
    }

    apply_blur
    "$upower" --monitor | while read -r _; do
      apply_blur
    done
  '';
in {
  systemd.user.services.mango-power-blur = {
    Unit = {
      Description = "Toggle Mango blur based on battery power";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${powerBlur}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
