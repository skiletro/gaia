# Service: mollysocket
# Dependencies: Caddy reverse proxy; sops-nix secret provisioning
# Data location:
#   Persistent state (secret environment may override the database path): /var/lib/mollysocket
{
  nixos = {
    config,
    mkCaddyProxy,
    ...
  }: let
    subdomain = "mollysocket";
    port = 8020;
  in {
    sops.secrets."mollysocket-env" = {};

    services.mollysocket = {
      enable = true;
      environmentFile = config.sops.secrets.mollysocket-env.path;
      settings = {
        inherit port;
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
