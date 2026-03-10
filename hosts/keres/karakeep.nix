{
  nixos =
    { config, ... }:
    let
      subdomain = "karakeep";
      domain = "warm.vodka";
      port = 3001;
    in
    {
      sops.secrets."pocketid-karakeep-secret" = { };

      sops.templates."karakeep.env".content =
        # env
        ''
          NEXTAUTH_URL="https://${subdomain}.${domain}"
          PORT="${toString port}"
          DISABLE_PASSWORD_AUTH=true
          DISABLE_NEW_RELEASE_CHECK=true

          OAUTH_AUTO_REDIRECT=true
          OAUTH_WELLKNOWN_URL="https://sso.warm.vodka/.well-known/openid-configuration"
          OAUTH_PROVIDER_NAME="Methanol"
          OAUTH_CLIENT_SECRET="${config.sops.placeholder.pocketid-karakeep-secret}"
          OAUTH_CLIENT_ID="f9713737-4a5a-4aed-b221-642b15850415"
        '';

      services.karakeep = {
        enable = true;
        meilisearch.enable = false; # what is the POINT of stateVersion if it doesn't WORK
        environmentFile = config.sops.templates."karakeep.env".path;
      };

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';
    };
}
