{
  lib,
  config,
  pkgs,
  inputs',
  ...
}:
{
  options.erebus.programs.wakatime.enable = lib.mkEnableOption "WakaTime";

  config = lib.mkIf config.erebus.programs.wakatime.enable {
    home.packages = [
      pkgs.wakatime-cli
      inputs'.wakatime-ls.packages.default
    ];

    home.sessionVariables.WAKATIME_HOME = "${config.xdg.configHome}/wakatime";

    xdg.configFile."wakatime/.wakatime.cfg".source = (pkgs.formats.ini { }).generate "wakatime-config" {
      settings = {
        api_url = "https://wt.warm.vodka/api";
        api_key_vault_cmd = "${pkgs.writeShellScript "cat-wakatime-api-key" "cat ${config.sops.secrets.wakapi-key.path}"}";
      };
    };

    sops.secrets."wakapi-key" = { };
  };
}
