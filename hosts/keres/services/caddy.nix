# Service: caddy
# Dependencies: none
# Data location:
#   Persistent Caddy state: /var/lib/caddy
#   Landing page: immutable Nix-store output
{inputs', ...}: {
  nixos = {keresDomain, ...}: {
    _module.args.mkCaddyProxy = subdomain: port: {
      "${subdomain}.${keresDomain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };

    services.caddy = {
      enable = true;
      virtualHosts."${keresDomain}" = {
        serverAliases = ["www.${keresDomain}"];
        extraConfig = let
          landingPage = inputs'.warm-vodka-landing-page.packages.default.override {
            title = keresDomain;
            links = builtins.mapAttrs (_: v: "https://${v}.${keresDomain}") {
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
              url = "https://sso.${keresDomain}";
            };
          };
        in
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
                        "href": "https://sso.${keresDomain}"
                      }
                    ]
                  }
                ` 200
            }

            handle {
              root * ${landingPage}
              file_server
            }
          '';
      };
    };
  };
}
