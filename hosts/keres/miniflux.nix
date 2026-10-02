{
  nixos = {config, ...}: let
    subdomain = "miniflux";
    domain = "warm.vodka";
    port = 3010;
  in {
    sops.secrets."pocketid-miniflux-secret" = {};

    services.miniflux = {
      enable = true;
      config = {
        PORT = toString port;
        BASE_URL = "https://${subdomain}.${domain}";
        HTTPS = 1;
        POLLING_FREQUENCY = 120;
        HTTP_CLIENT_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0";
        CREATE_ADMIN = 0;
        DISABLE_LOCAL_AUTH = 1;
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_OIDC_PROVIDER_NAME = "Methanol";
        OAUTH2_CLIENT_ID = "266a4351-916b-49b5-aa29-f841f127b662";
        OAUTH2_CLIENT_SECRET_FILE = "%d/oidc-client-secret";
        OAUTH2_REDIRECT_URL = "https://${subdomain}.${domain}/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.${domain}";
        OAUTH2_USER_CREATION = 1;
      };
    };

    systemd.services.miniflux.serviceConfig.LoadCredential = [
      "oidc-client-secret:${config.sops.secrets.pocketid-miniflux-secret.path}"
    ];

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';
  };
}
