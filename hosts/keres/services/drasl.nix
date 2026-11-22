# Service: Drasl
# Dependencies: Caddy reverse proxy
# Data location:
#   Persistent application state: /var/lib/drasl
{
  nixos = {
    mkCaddyProxy,
    keresDomain,
    ...
  }: let
    subdomain = "drasl";
    port = 3002;
  in {
    services.drasl = {
      enable = true;
      settings = {
        Domain = "${subdomain}.${keresDomain}";
        BaseURL = "https://${subdomain}.${keresDomain}";
        InstanceName = "Martini";
        ApplicationOwner = keresDomain;
        ListenAddress = "127.0.0.1:${toString port}";
        DefaultAdmins = ["jamie"];
        # One Minecraft player per account; no extra players after registration.
        DefaultMaxPlayerCount = 1;
        CreateNewPlayer.Allow = false;
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
