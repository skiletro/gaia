{
  nixos = {config, ...}: let
    subdomain = "sso";
    domain = "warm.vodka";
    port = 1411;
  in {
    sops.secrets = {
      "pocketid-encryption-key" = {
        owner = "pocket-id";
        group = "pocket-id";
      };
      "pocketid-smtp-pass" = {};
    };

    services.pocket-id = {
      enable = true;
      settings = {
        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
        APP_URL = "https://${subdomain}.${domain}";

        # UI
        UI_CONFIG_DISABLED = true;
        APP_NAME = "Methanol";
        ALLOW_USER_SIGNUPS = "withToken";
        SMTP_HOST = "smtp.protonmail.ch";
        SMTP_PORT = "587";
        SMTP_USER = "${"noreply"}${"@"}${"warm.vodka"}";
        SMTP_FROM = "${"noreply"}${"@"}${"warm.vodka"}";
        SMTP_TLS = "starttls";
        EMAIL_ONE_TIME_ACCESS_AS_UNAUTHENTICATED_ENABLED = true;
        EMAIL_VERIFICATION_ENABLED = true;
        EMAIL_API_KEY_EXPIRATION_ENABLED = true;
        EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
      };
      credentials = {
        ENCRYPTION_KEY = config.sops.secrets.pocketid-encryption-key.path;
        SMTP_PASSWORD = config.sops.secrets.pocketid-smtp-pass.path;
      };
    };

    services.caddy.virtualHosts = {
      "${subdomain}.${domain}".extraConfig =
        # caddyfile
        ''
          reverse_proxy :${toString port}
        '';
    };
  };
}
