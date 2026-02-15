{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  cfg = config.programs'.wakatime;
  iniFormat = pkgs.format.ini { };
in
{
  options.programs'.wakatime = {
    enable = lib.mkEnableOption "WakaTime";
    settings = lib.mkOption {
      description = "WakaTime configurations settings as an attribute set";
      inherit (iniFormat) type;
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
}
