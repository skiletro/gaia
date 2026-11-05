# Service: broadcast-box
# Dependencies: Caddy reverse proxy; sops-nix secret provisioning
# Data location:
#   Persistent state and working directory: /var/lib/broadcast-box
{self', ...}: {
  nixos = {
    config,
    mkCaddyProxy,
    ...
  }: let
    subdomain = "box";
    port = 8090;
  in {
    sops.secrets."broadcast-box-env" = {};

    services.broadcast-box = {
      enable = true;
      package = self'.packages.broadcast-box;
      web = {
        host = "127.0.0.1";
        inherit port;
      };
      openFirewall = true;
      settings = {
        UDP_MUX_PORT = port;
        INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP = true;
        STREAM_PROFILE_POLICY = "RESERVED";
      };
    };

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;

    systemd.services.broadcast-box.serviceConfig = {
      StateDirectory = "broadcast-box";
      WorkingDirectory = "/var/lib/broadcast-box";
      EnvironmentFile = config.sops.secrets.broadcast-box-env.path;
    };
  };
}
