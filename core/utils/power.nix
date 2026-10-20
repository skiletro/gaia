{
  config,
  lib,
  ...
}: let
  power = config.gaia.device.power;
  noctaliaEnabled = config.gaia.services.noctalia.enable or false;
  policyEnabled = power.enable && noctaliaEnabled;
  timeoutOption = default: description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      inherit default description;
    };
in {
  options.gaia.device.power = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.gaia.device.type == "laptop";
      description = "Apply battery idle policy to Noctalia when enabled.";
    };
    idle.battery = {
      lockTimeout = timeoutOption 300 "Battery lock timeout in seconds; null disables locking.";
      screenOffTimeout = timeoutOption 360 "Battery screen-off timeout in seconds; null disables screen-off.";
      suspendTimeout = timeoutOption 900 "Battery lock-and-suspend timeout in seconds; null disables suspension.";
    };
  };

  config = lib.mkIf policyEnabled {
    nixos.services.upower.enable = true;

    home-manager = {
      config,
      pkgs,
      ...
    }: let
      idleOverride = "${config.xdg.configHome}/noctalia/zz-power-idle.toml";
      batteryBehavior = timeout:
        {enabled = timeout != null;}
        // lib.optionalAttrs (timeout != null) {timeout = timeout * 1.0;};
      batteryIdle = (pkgs.formats.toml {}).generate "noctalia-battery-idle.toml" {
        idle.behavior = {
          lock = batteryBehavior power.idle.battery.lockTimeout;
          screen-off = batteryBehavior power.idle.battery.screenOffTimeout;
          lock-and-suspend = batteryBehavior power.idle.battery.suspendTimeout;
        };
      };
      powerPolicy = pkgs.writeShellApplication {
        name = "gaia-power-policy";
        runtimeInputs = with pkgs; [coreutils diffutils systemd upower];
        text =
          lib.toShellVars {
            noctalia_override = idleOverride;
            noctalia_battery = "${batteryIdle}";
          }
          + "\n"
          + builtins.readFile ./power.sh;
      };
    in {
      systemd.user.services.gaia-power-policy = {
        Unit = {
          Description = "Apply host battery idle policy to Noctalia";
          After = ["graphical-session.target"];
          Before = ["noctalia.service"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStartPre = "${lib.getExe powerPolicy} --once";
          ExecStart = lib.getExe powerPolicy;
          ExecStopPost = "${lib.getExe powerPolicy} --restore";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
