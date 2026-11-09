# Service: pocket-id
# Dependencies: Caddy reverse proxy; SMTP relay; sops-nix secret provisioning
# Data location:
#   Persistent application state: /var/lib/pocket-id
{
  nixos = {
    config,
    mkCaddyProxy,
    keresDomain,
    ...
  }: let
    subdomain = "sso";
    port = 1411;
  in {
    sops.secrets."pocketid-env".restartUnits = ["pocket-id.service"];

    services.pocket-id = {
      enable = true;
      environmentFile = config.sops.secrets."pocketid-env".path;
      settings = {
        TRUST_PROXY = true;
        ANALYTICS_DISABLED = true;
        APP_URL = "https://${subdomain}.${keresDomain}";

        # UI
        UI_CONFIG_DISABLED = true;
        APP_NAME = "Methanol";
        ALLOW_USER_SIGNUPS = "withToken";
        SMTP_HOST = "smtp.protonmail.ch";
        SMTP_PORT = "587";
        SMTP_USER = "noreply@${keresDomain}";
        SMTP_FROM = "noreply@${keresDomain}";
        SMTP_TLS = "starttls";
        EMAIL_ONE_TIME_ACCESS_AS_UNAUTHENTICATED_ENABLED = true;
        EMAIL_VERIFICATION_ENABLED = true;
        EMAIL_API_KEY_EXPIRATION_ENABLED = true;
        EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
