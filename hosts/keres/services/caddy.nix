{ lib, config, ... }:
let
  cfg = config.erebus.selfhost;
  inherit (lib) mkOption types;
  domain = "warm.vodka";
in
{
  options.erebus.selfhost = {
    domain = mkOption {
      type = types.str;
      default = domain;
    };

    services = mkOption {
      type = types.attrsOf types.int;
      default = { };
      example = {
        karakeep = 3000;
        minecraft = 25565;
        wakapi = 3001;
      };
    };
  };

  config = {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "${domain}" = {
          serverAliases = [
            "www.${domain}"
          ];
          extraConfig = ''
            header Content-Type text/html
            respond "eos"
          '';
        };
      }
      // lib.mapAttrs' (subdomain: port: {
        name = "${subdomain}.${domain}";
        value.extraConfig = ''
          reverse_proxy :${toString port}
        '';
      }) cfg.services;
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
