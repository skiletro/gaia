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
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
