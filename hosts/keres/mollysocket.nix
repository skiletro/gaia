{
  nixos = {config, ...}: let
    subdomain = "mollysocket";
    domain = "warm.vodka";
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

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';
  };
}
