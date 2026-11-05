# Service: caddy
# Dependencies: none
# Data location:
#   Persistent Caddy state: /var/lib/caddy
#   Landing page: immutable Nix-store output
{inputs', ...}: {
  nixos = let
    domain = "warm.vodka";

    links = builtins.mapAttrs (_: v: "https://${v}.${domain}") {
      # keep-sorted start
      broadcast-box = "box";
      forgejo = "git";
      maloja = "maloja";
      miniflux = "miniflux";
      mollysocket = "mollysocket";
      navidrome = "navidrome";
      romm = "romm";
      wakapi = "wakapi";
      # keep-sorted end
    };

    accountLink = {
      label = "manage your methanol account";
      url = "https://sso.${domain}";
    };
  in {
    _module.args.mkCaddyProxy = subdomain: port: {
      "${subdomain}.${domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };

    services.caddy = {
      enable = true;
      virtualHosts."${domain}" = {
        serverAliases = ["www.${domain}"];
        extraConfig =
          # caddyfile
          ''
            handle /.well-known/webfinger {
              header Content-Type application/jrd+json
                respond `
                  {
                    "subject": "{query.resource}",
                    "links": [
                      {
                        "rel": "http://openid.net/specs/connect/1.0/issuer",
                        "href": "https://sso.${domain}"
                      }
                    ]
                  }
                ` 200
            }

            handle {
              root * ${(inputs'.warm-vodka-landing-page.packages.default.override {
              title = domain;
              inherit links accountLink;
            })}
              file_server
            }
          '';
      };
    };
  };
}
