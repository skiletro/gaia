{ bundleLib, inputs', ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "wakatime" ] {

  home-manager =
    { pkgs, config, ... }:
    {
      home.packages = [
        pkgs.wakatime-cli
        inputs'.wakatime-ls.packages.default
      ];

      home.sessionVariables.WAKATIME_HOME = "${config.xdg.configHome}/wakatime";

      xdg.configFile."wakatime/.wakatime.cfg".source =
        (pkgs.formats.ini { }).generate "gaia-wakatime-cfg"
          {
            settings = {
              api_url = "https://wakapi.warm.vodka/api";
              api_key_vault_cmd = "${pkgs.writeShellScript "cat-wakatime-api-key" "cat ${config.sops.secrets.wakapi-key.path}"}";
            };
          };

      sops.secrets."wakapi-key" = { };
    };

}
