{
  nixos = let
    subdomain = "git";
    domain = "warm.vodka";
    port = 3000;
  in {
    services.forgejo = {
      enable = true;
      # Persistent state: repositories, SQLite database, uploads, config, secrets, and logs.
      stateDir = "/var/lib/forgejo";
      database.type = "sqlite3";
      settings = {
        server = {
          DOMAIN = "${subdomain}.${domain}";
          ROOT_URL = "https://${subdomain}.${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = port;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
