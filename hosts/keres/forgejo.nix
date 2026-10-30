{
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    subdomain = "git";
    domain = "warm.vodka";
    port = 3000;
    themeVersion = "1.3.0";
    themeBase = pkgs.fetchurl {
      url = "https://github.com/whereareiam/forgejo-github-theme/releases/download/${themeVersion}/theme-github-base.tar.gz";
      hash = "sha256-1lWT9pdnSnOxPzdwrjz8lyMX0J/b/G2vR9um0oxzM+E=";
    };
    themeExtras = pkgs.fetchurl {
      url = "https://github.com/whereareiam/forgejo-github-theme/releases/download/${themeVersion}/theme-github-extras.tar.gz";
      hash = "sha256-z1oWUwqAf1zI26nt/ayskYyrpwc/lC6ul+I6x4AYByI=";
    };
    themeTemplates = pkgs.fetchurl {
      url = "https://github.com/whereareiam/forgejo-github-theme/releases/download/${themeVersion}/theme-github-templates.tar.gz";
      hash = "sha256-6TCiWtEkv1362gGU/4jS7A+p3Tnzl2OTO7LvfQSHfEA=";
    };
    githubTheme = pkgs.runCommand "forgejo-github-theme-${themeVersion}" {} ''
      mkdir -p "$out/public/assets/css"
      tar -xzf ${themeTemplates} -C "$out"
      tar -xzf ${themeBase} -C "$out/public/assets/css"
      tar -xzf ${themeExtras} -C "$out/public/assets/css" --wildcards 'theme-github-pink-*.css'
    '';
  in {
    assertions = [
      {
        assertion = lib.versions.major config.services.forgejo.package.version == "17";
        message = "Forgejo GitHub Theme ${themeVersion} targets Forgejo 17; review theme compatibility before upgrading Forgejo.";
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
          DEFAULT_THEME = "github-pink-auto";
          THEMES = "github-auto,github-light,github-dark,github-soft-dark,github-pink-auto,github-pink-light,github-pink-dark,github-pink-soft-dark";
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
