{ config, ... }:
let
  inherit (config.erebus.selfhost) domain;
  subdomain = "wt";
  port = 3009;
in
{
  sops.secrets."wakapi-env" = {
    owner = "wakapi";
    group = "wakapi";
    mode = "0400";
  };

  # ty https://github.com/not-matthias/dotfiles-nix/blob/cdd911cbdc585331cead87b7296a0e2e5206e257/modules/system/services/wakapi.nix#L49 :)
  services.wakapi = {
    enable = true;
    environmentFiles = [ config.sops.secrets.wakapi-salt.path ];
    settings = {
      server = {
        public_url = "https://${subdomain}.${domain}";
        listen_ipv4 = "127.0.0.1";
        listen_ipv6 = "-";
        inherit port;
      };
      db.dialect = "sqlite3";
      security.allow_signup = false;
      app = {
        aggregation_time = "0 15 2 * * *";
        report_time_weekly = "0 0 18 * * 5";
        data_cleanup_time = "0 0 6 * * 0";
        import_enabled = true;
        leaderboard_enabled = false;
      };
    };
  };

  erebus.selfhost.services = {
    ${subdomain} = port;
  };
}
