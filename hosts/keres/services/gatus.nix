# Service: Gatus
# Dependencies: Caddy; public DNS and HTTPS access to the monitored applications
# Data location:
#   SQLite monitoring history: /var/lib/gatus/gatus.db
#   Theme assets: immutable Nix-store output, served by Caddy
{
  nixos = {
    config,
    lib,
    pkgs,
    keresDomain,
    ...
  }: let
    port = 8081;
    httpEndpoints = [
      {
        name = "Broadcast Box";
        logo = "broadcast-box.ico";
        url = "https://box.${keresDomain}/";
      }
      {
        name = "Forgejo";
        logo = "forgejo.svg";
        url = "https://git.${keresDomain}/api/healthz";
        conditions = [
          "[STATUS] == 200"
          "[BODY].status == pass"
        ];
      }
      {
        name = "Maloja";
        logo = "maloja.png";
        url = "https://maloja.${keresDomain}/apis/mlj_1/serverinfo";
        conditions = [
          "[STATUS] == 200"
          "[BODY].db_status.healthy == true"
        ];
      }
      {
        name = "Miniflux";
        logo = "miniflux.svg";
        url = "https://miniflux.${keresDomain}/healthcheck";
        conditions = [
          "[STATUS] == 200"
          "[BODY] == OK"
        ];
      }
      {
        name = "MollySocket";
        # MollySocket has no separate mark; use the parent Molly project's logo.
        logo = "molly.svg";
        url = "https://mollysocket.${keresDomain}/";
      }
      {
        name = "Navidrome";
        logo = "navidrome.svg";
        url = "https://navidrome.${keresDomain}/ping";
      }
      {
        name = "Pocket ID";
        logo = "pocket-id.svg";
        url = "https://sso.${keresDomain}/healthz";
        conditions = ["[STATUS] == 204"];
      }
      {
        name = "RomM";
        logo = "romm.svg";
        url = "https://romm.${keresDomain}/api/heartbeat";
      }
      {
        name = "Wakapi";
        logo = "wakapi.svg";
        url = "https://wakapi.${keresDomain}/api/health";
        conditions = [
          "[STATUS] == 200"
          "[BODY] == pat(*app=1*)"
          "[BODY] == pat(*db=1*)"
        ];
      }
      {
        name = "Website / Caddy";
        logo = "caddy.svg";
        group = "Infrastructure";
        url = "https://${keresDomain}/";
      }
    ];
    postgresqlEndpoint = {
      name = "PostgreSQL";
      logo = "postgresql.svg";
      group = "Infrastructure";
      url = "tcp://127.0.0.1:${toString config.services.postgresql.settings.port}";
      interval = "1m";
      client.timeout = "10s";
      # Listener availability, not an authenticated database query.
      conditions = ["[CONNECTED] == true"];
    };
    broadcastSource = config.services.broadcast-box.package.src;
    fontSource = "${config.stylix.fonts.sansSerif.package.src}/SpaceGrotesk-2.0.0";
    themeAssets = pkgs.linkFarm "gatus-theme-assets" (
      lib.mapAttrsToList (name: source: {
        inherit name;
        path = pkgs.fetchurl source;
      }) (builtins.fromJSON (builtins.readFile ./gatus/logos.json))
      ++ [
        {
          name = "broadcast-box.ico";
          path = "${broadcastSource}/web/public/favicon.ico";
        }
        {
          name = "broadcast-box-LICENSE";
          path = "${broadcastSource}/LICENSE";
        }
        {
          name = "space-grotesk.woff2";
          path = "${fontSource}/woff2/SpaceGrotesk[wght].woff2";
        }
        {
          name = "space-grotesk-OFL.txt";
          path = "${fontSource}/OFL.txt";
        }
        {
          name = "CREDITS.txt";
          path = pkgs.writeText "gatus-theme-credits" ''
            Service marks identify their respective projects; no endorsement is implied.
            Dashboard Icons: https://github.com/homarr-labs/dashboard-icons
            Broadcast Box favicon: https://github.com/Glimesh/broadcast-box
            Molly logo by jaim3: https://github.com/mollyim/mollyim.github.io
            Space Grotesk by Florian Karsten: https://github.com/floriankarsten/space-grotesk
            Source URLs and hashes: hosts/keres/services/gatus/logos.json in Gaia.
            License notices are served alongside these assets.
          '';
        }
      ]
    );
    colorKeys =
      builtins.filter
      (key: builtins.match "base0[0-9A-F]" key != null)
      (builtins.attrNames config.lib.stylix.colors);
    themeCss =
      lib.replaceStrings
      ((map (color: "@${color}@") colorKeys) ++ ["@radius@"])
      ((map (color: config.lib.stylix.colors.withHashtag.${color}) colorKeys) ++ [(toString config.stylix.borderRadius)])
      (builtins.readFile ./gatus/theme.css);
    logoCss = lib.concatMapStringsSep "\n" (endpoint: ''
      #global .endpoint-header [role="link"][title=${builtins.toJSON endpoint.name}] {
        --service-logo: url("/theme/${endpoint.logo}");
      }
    '') (httpEndpoints ++ [postgresqlEndpoint]);
  in {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          inherit port;
        };
        ui = {
          title = "${keresDomain} status";
          header = "${keresDomain}";
          link = "https://${keresDomain}";
          custom-css = themeCss + logoCss;
        };
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/gatus.db";
        };
        endpoints =
          map (endpoint:
            {
              group = "Applications";
              interval = "1m";
              client = {
                timeout = "10s";
                ignore-redirect = true;
              };
              conditions = ["[STATUS] == 200"];
            }
            // removeAttrs endpoint ["logo"])
          httpEndpoints
          ++ [(removeAttrs postgresqlEndpoint ["logo"])];
      };
    };

    services.caddy.virtualHosts."status.${keresDomain}".extraConfig = ''
      handle_path /theme/* {
        root * ${themeAssets}
        file_server
      }
      handle {
        reverse_proxy 127.0.0.1:${toString port}
      }
    '';
  };
}
