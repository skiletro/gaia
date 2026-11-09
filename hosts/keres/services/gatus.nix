# Service: Gatus
# Dependencies: Caddy; public DNS and HTTPS access to the monitored applications
# Data location:
#   SQLite monitoring history: /var/lib/gatus/gatus.db
{
  nixos = {
    config,
    mkCaddyProxy,
    keresDomain,
    ...
  }: let
    port = 8081;
    httpEndpoints = [
      {
        name = "Broadcast Box";
        url = "https://box.${keresDomain}/";
      }
      {
        name = "Forgejo";
        url = "https://git.${keresDomain}/api/healthz";
        conditions = [
          "[STATUS] == 200"
          "[BODY].status == pass"
        ];
      }
      {
        name = "Maloja";
        url = "https://maloja.${keresDomain}/apis/mlj_1/serverinfo";
        conditions = [
          "[STATUS] == 200"
          "[BODY].db_status.healthy == true"
        ];
      }
      {
        name = "Miniflux";
        url = "https://miniflux.${keresDomain}/healthcheck";
        conditions = [
          "[STATUS] == 200"
          "[BODY] == OK"
        ];
      }
      {
        name = "MollySocket";
        url = "https://mollysocket.${keresDomain}/";
      }
      {
        name = "Navidrome";
        url = "https://navidrome.${keresDomain}/ping";
      }
      {
        name = "Pocket ID";
        url = "https://sso.${keresDomain}/healthz";
        conditions = ["[STATUS] == 204"];
      }
      {
        name = "RomM";
        url = "https://romm.${keresDomain}/api/heartbeat";
      }
      {
        name = "Wakapi";
        url = "https://wakapi.${keresDomain}/api/health";
        conditions = [
          "[STATUS] == 200"
          "[BODY] == pat(*app=1*)"
          "[BODY] == pat(*db=1*)"
        ];
      }
      {
        name = "Website / Caddy";
        group = "Infrastructure";
        url = "https://${keresDomain}/";
      }
    ];
  in {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          inherit port;
        };
        ui = {
          title = "${keresDomain} status";
          header = "${keresDomain}";
          link = "https://${keresDomain}";
        };
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/gatus.db";
        };
        endpoints =
          map (endpoint:
            {
              group = "Applications";
              interval = "1m";
              client = {
                timeout = "10s";
                ignore-redirect = true;
              };
              conditions = ["[STATUS] == 200"];
            }
            // endpoint)
          httpEndpoints
          ++ [
            {
              name = "PostgreSQL";
              group = "Infrastructure";
              url = "tcp://127.0.0.1:${toString config.services.postgresql.settings.port}";
              interval = "1m";
              client.timeout = "10s";
              # Listener availability, not an authenticated database query.
              conditions = ["[CONNECTED] == true"];
            }
          ];
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy "status" port;
  };
}
