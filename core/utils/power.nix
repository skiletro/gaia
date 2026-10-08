{
  config,
  lib,
  ...
}: let
  power = config.gaia.device.power;
  noctaliaEnabled = config.gaia.services.noctalia.enable or false;
  mangoEnabled = config.gaia.desktops.mango.enable or false;
  policyEnabled = power.enable && (noctaliaEnabled || mangoEnabled);
  mangoBlurEnabled = mangoEnabled && power.disableBlurOnBattery;
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
      description = "Apply battery power policy to enabled desktop consumers.";
    };
    idle.battery = {
      lockTimeout = timeoutOption 300 "Battery lock timeout in seconds; null disables locking.";
      screenOffTimeout = timeoutOption 360 "Battery screen-off timeout in seconds; null disables screen-off.";
      suspendTimeout = timeoutOption 900 "Battery lock-and-suspend timeout in seconds; null disables suspension.";
    };
    disableBlurOnBattery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable Mango window and layer blur while on battery.";
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
      mangoOverride = "${config.xdg.configHome}/mango/power.conf";
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
      mangoBattery = pkgs.writeText "mango-battery-power.conf" ''
        blur=0
        blur_layer=0
        blur_optimized=1
      '';
      mangoAC = pkgs.writeText "mango-ac-power.conf" ''
        blur=1
        blur_layer=1
        blur_optimized=0
      '';
      powerPolicy = pkgs.writeShellApplication {
        name = "gaia-power-policy";
        runtimeInputs = with pkgs; [coreutils diffutils systemd upower];
        text =
          lib.toShellVars {
            noctalia_override =
              if noctaliaEnabled
              then idleOverride
              else "";
            noctalia_battery =
              if noctaliaEnabled
              then "${batteryIdle}"
              else "";
            mango_override =
              if mangoBlurEnabled
              then mangoOverride
              else "";
            mango_battery =
              if mangoBlurEnabled
              then "${mangoBattery}"
              else "";
            mango_ac =
              if mangoBlurEnabled
              then "${mangoAC}"
              else "";
            mango_ipc =
              if mangoBlurEnabled
              then lib.getExe' config.wayland.windowManager.mango.package "mmsg"
              else "";
          }
          + "\n"
          + builtins.readFile ./power.sh;
      };
    in {
      systemd.user.services.gaia-power-policy = {
        Unit = {
          Description = "Apply host battery policy to desktop consumers";
          After = ["graphical-session.target"];
          Before = lib.optional noctaliaEnabled "noctalia.service";
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
