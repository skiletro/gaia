{ inputs, lib, ... }:
{
  nixos =
    { config, pkgs, ... }:
    {
      options.programs.steam = {
        defaultCompatTool = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        apps = lib.mkOption {
          type = lib.types.nullOr lib.types.attrs;
          default = null;
        };
      };

      config = lib.mkIf config.programs.steam.enable {
        environment.systemPackages = with pkgs; [
          # sgdboop # Setting SteamGridDB art easier
          steamtinkerlaunch
        ];
        boot.kernel.sysctl."vm.max_map_count" = 2147483642; # Some Steam games like this, idk why

        programs.steam.package = pkgs.steam.override {
          extraProfile = ''
            export DXVK_HUD=compiler,fps
            export PROTON_ENABLE_WAYLAND=1
            export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
            unset TZ
          '';
        };
      };
    };

  home-manager =
    { osConfig, ... }:
    {
      imports = lib.singleton inputs.steam-config-nix.homeModules.default;
      programs.steam.config = {
        enable = lib.mkIf osConfig.programs.steam.enable true;
        closeSteam = true;
        inherit (osConfig.programs.steam) apps defaultCompatTool;
      };
    };

  darwin = throw "gaia: 'steam' is not yet available on macos.";
}
