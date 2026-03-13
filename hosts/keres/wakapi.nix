{
  nixos =
    { config, ... }:
    let
      subdomain = "wakapi";
      domain = "warm.vodka";
      port = 3009;
    in
    {
      sops.secrets."wakapi-env" = {
        owner = "wakapi";
        group = "wakapi";
        mode = "0400";
      };

      services.wakapi = {
        enable = true;
        environmentFiles = [ config.sops.secrets.wakapi-env.path ];
        settings = {
          server = {
            public_url = "https://${subdomain}.${domain}";
            listen_ipv4 = "127.0.0.1";
            listen_ipv6 = "-";
            inherit port;
          };
          security.disable_frontpage = true;
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
