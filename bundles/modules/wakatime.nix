{
  lib,
  inputs',
  ...
}:
{
  home-manager =
    { config, pkgs, ... }:
    let
      cfg = config.programs'.wakatime;
      iniFormat = pkgs.formats.ini { };
    in
    {
      options.programs'.wakatime = {
        enable = lib.mkEnableOption "WakaTime";
        settings = lib.mkOption {
          description = "WakaTime configurations settings as an attribute set";
          type = lib.types.attrs;
          default = { };
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [
          pkgs.wakatime-cli
          inputs'.wakatime-ls.packages.default
        ];

        home.sessionVariables.WAKATIME_HOME = "${config.xdg.configHome}/wakatime";

        xdg.configFile."wakatime/.wakatime.cfg".source = iniFormat.generate "gaia-wakatime-cfg" {
          inherit (cfg) settings;
        };
      };
    };
}
