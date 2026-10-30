{self', ...}: {
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    subdomain = "git";
    domain = "warm.vodka";
    port = 3000;
    githubTheme = self'.packages.forgejo-github-theme;
  in {
    assertions = [
      {
        assertion = lib.versions.major config.services.forgejo.package.version == "17";
        message = "The pinned skiletro/forgejo-github-theme templates target Forgejo 17; review compatibility before upgrading Forgejo.";
      }
    ];

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
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
        ui = {
          DEFAULT_THEME = "github-warm-vodka-dark";
          THEMES = "github-warm-vodka-dark";
        };
      };
    };

    # Keep configuration and secrets writable; serve pinned theme assets from the store.
    systemd.tmpfiles.rules = [
      "L+ ${config.services.forgejo.customDir}/public - - - - ${githubTheme}/public"
      "L+ ${config.services.forgejo.customDir}/templates - - - - ${githubTheme}/templates"
    ];
    systemd.services.forgejo.restartTriggers = [githubTheme];

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
