{
  nixos = {config, ...}: let
    subdomain = "wakapi";
    domain = "warm.vodka";
    port = 3009;
  in {
    sops = {
      secrets = {
        "wakapi-password-salt" = {};
        "wakapi-oidc-client-secret" = {};
      };
      templates."wakapi-env" = {
        owner = "wakapi";
        group = "wakapi";
        mode = "0400";
        restartUnits = ["wakapi.service"];
        content = let
          secret = config.sops.placeholder;
        in ''
          WAKAPI_PASSWORD_SALT=${secret."wakapi-password-salt"}
          WAKAPI_OIDC_PROVIDERS_0_CLIENT_SECRET=${secret."wakapi-oidc-client-secret"}
        '';
      };
    };

    services.wakapi = {
      enable = true;
      environmentFiles = [config.sops.templates."wakapi-env".path];
      settings = {
        server = {
          public_url = "https://${subdomain}.${domain}";
          listen_ipv4 = "127.0.0.1";
          listen_ipv6 = "-";
          inherit port;
        };
        security = {
          disable_frontpage = true;
          allow_signup = true;
          oidc_allow_signup = true;
          disable_local_auth = true;
          oidc = [
            {
              name = "pocket-id";
              display_name = "Methanol";
              client_id = "0b4fae56-5e6e-4633-b280-93f0d15a6d61";
              endpoint = "https://sso.${domain}";
              username_claim = "display_name";
            }
          ];
        };
        mail.skip_verify_mx_record = true;
        db.dialect = "sqlite3";
        app = {
          aggregation_time = "0 15 2 * * *";
          report_time_weekly = "0 0 18 * * 5";
          data_cleanup_time = "0 0 6 * * 0";
          import_enabled = true;
          leaderboard_enabled = false;
        };
      };
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';
  };
}
