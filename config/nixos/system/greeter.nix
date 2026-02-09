{
  config,
  lib,
  ...
}:
let
  inherit (config.erebus.system) greeter;
  inherit (lib)
    mkMerge
    mkOption
    mkIf
    types
    ;
in
{
  options.erebus.system.greeter = mkOption {
    type = types.nullOr (
      types.enum [
        "dankgreeter"
        "gdm"
      ]
    );
    default = null;
  };

  config = mkMerge [
    (mkIf (greeter == "gdm") {
      services.displayManager.gdm.enable = true;
    })
    (mkIf (greeter == "dankgreeter") {
      services.displayManager.dms-greeter = {
        enable = true;
        compositor = {
          name = "sway";
          customConfig = ''
            output DP-3 {
              mode 3440x1440@165Hz
            }

            input * {
              accel_profile flat
              pointer_accel 0.6
            }

            seat * xcursor_theme ${config.stylix.cursor.name} ${toString config.stylix.cursor.size}
          '';
        };
        configHome = "/home/jamie";
      };
      programs.sway = {
        enable = true;
        extraPackages = lib.mkDefault [ ];
      };
    })
  ];
}
