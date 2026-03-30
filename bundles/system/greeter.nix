{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "system" "greeter" ] {

  nixos =
    { config, ... }:
    {
      services.displayManager.dms-greeter = {
        enable = true;
        compositor = {
          name = "sway";
          customConfig = ''
            output DP-3 {
              mode 3440x1440@175Hz
            }

            input * {
              accel_profile flat
              pointer_accel 0.6
            }

            seat seat0 xcursor_theme ${config.stylix.cursor.name} ${toString config.stylix.cursor.size}
          '';
        };
        configHome = "/home/jamie";
      };
      programs.sway = {
        enable = true;
        extraPackages = lib.mkDefault [ config.stylix.cursor.package ];
      };
    };

  darwin = throw "gaia: greeters are unsupported on macos";

}
