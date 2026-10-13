{self', ...}: {
  nixos = {config, ...}: let
    subdomain = "box";
    domain = "warm.vodka";
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

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';

    systemd.services.broadcast-box.serviceConfig = {
      StateDirectory = "broadcast-box";
      WorkingDirectory = "/var/lib/broadcast-box";
      EnvironmentFile = config.sops.secrets.broadcast-box-env.path;
    };
  };
}
