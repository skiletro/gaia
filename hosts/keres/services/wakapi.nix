# Service: wakapi
# Dependencies: Caddy reverse proxy; Pocket ID OIDC; sops-nix secret provisioning
# Data location:
#   SQLite database and persistent application state: /var/lib/wakapi
{
  nixos = {
    config,
    pkgs,
    mkCaddyProxy,
    keresDomain,
    ...
  }: let
    subdomain = "wakapi";
    port = 3009;
    oidcEndpoint = "https://sso.${keresDomain}";
  in {
    sops.secrets."wakapi-env" = {
      owner = "wakapi";
      group = "wakapi";
      mode = "0400";
      restartUnits = ["wakapi.service"];
    };

    services.wakapi = {
      enable = true;
      environmentFiles = [config.sops.secrets."wakapi-env".path];
      settings = {
        server = {
          public_url = "https://${subdomain}.${keresDomain}";
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
              endpoint = oidcEndpoint;
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

    systemd.services.wakapi = {
      wants = ["caddy.service" "pocket-id.service"];
      after = ["caddy.service" "pocket-id.service"];
      # Discovery needs the HTTPS proxy and issuer ready, not just their processes.
      preStart = ''
        echo "Waiting for OIDC discovery at ${oidcEndpoint}"
        until ${pkgs.curl}/bin/curl --fail --silent --show-error \
          --connect-timeout 5 --max-time 10 --output /dev/null \
          "${oidcEndpoint}/.well-known/openid-configuration"; do
          sleep 2
        done
      '';
      serviceConfig = {
        TimeoutStartSec = "2min";
        RestartSec = "5s";
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
