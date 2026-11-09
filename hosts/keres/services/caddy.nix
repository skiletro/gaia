# Service: caddy
# Dependencies: none
# Data location:
#   Persistent Caddy state: /var/lib/caddy
#   Landing page: immutable Nix-store output
{inputs', ...}: {
  nixos = {
    config,
    keresDomain,
    ...
  }: {
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
            colors = with config.lib.stylix.colors.withHashtag; {
              background0 = base00;
              background1 = base01;
              background2 = base02;
              background3 = base03;
              foreground0 = base05;
              foreground1 = base04;
              foreground2 = base0D;
              accent = base0D;
              box-border-color = base03;
            };
            links = builtins.mapAttrs (_: v: "https://${v}.${keresDomain}") {
              # keep-sorted start
              broadcast-box = "box";
              forgejo = "git";
              maloja = "maloja";
              miniflux = "miniflux";
              mollysocket = "mollysocket";
              navidrome = "navidrome";
              romm = "romm";
              status = "status";
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
