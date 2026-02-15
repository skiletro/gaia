{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "wakatime" ] {

  home-manager =
    { pkgs, config, ... }:
    {
      programs'.wakatime = {
        enable = true;
        settings = {
          api_url = "https://wt.warm.vodka/api";
          api_key_vault_cmd = "${pkgs.writeShellScript "cat-wakatime-api-key" "cat ${config.sops.secrets.wakapi-key.path}"}";
        };
      };

      sops.secrets."wakapi-key" = { };
    };

}
