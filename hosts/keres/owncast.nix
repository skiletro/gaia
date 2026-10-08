{
  nixos = let
    subdomain = "owncast";
    domain = "warm.vodka";
    port = 8090;
    rtmpPort = 1935;
  in {
    services.owncast = {
      enable = true;
      listen = "127.0.0.1";
      inherit port;
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';

    networking.firewall.allowedTCPPorts = [rtmpPort];
  };
}
