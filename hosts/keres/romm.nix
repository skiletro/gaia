{
  nixos = {
    lib,
    config,
    ...
  }: let
    subdomain = "romm";
    domain = "warm.vodka";
    # port the nginx virtual host listens on; caddy proxies to it
    port = 8585;
  in {
    nixpkgs.overlays = [
      # nginx-mod-zip trips -Werror on gcc 15 (unused-but-set-variable);
      # upstream is unmaintained, so demote that one warning. the module is
      # compiled inside the nginx build, so the flag goes via passthru.forNginx
      (_final: prev: {
        nginxModules =
          prev.nginxModules
          // {
            zip = prev.nginxModules.zip.overrideAttrs (old: {
              passthru =
                (old.passthru or {})
                // {
                  forNginx = oldNginx: {
                    env =
                      (oldNginx.env or {})
                      // {
                        # append: generic.nix already sets NIX_CFLAGS_COMPILE
                        # with the libxml2 include path
                        NIX_CFLAGS_COMPILE =
                          (oldNginx.env.NIX_CFLAGS_COMPILE or "")
                          + " -Wno-error=unused-but-set-variable";
                      };
                  };
                };
            });
          };
      })
    ];

    services.romm = {
      enable = true;
      dataDir = "/srv/romm";
      nginx.virtualHost = "${subdomain}.${domain}";
      extraEnvironment = {
        # the module derives an http:// URL from the nginx virtual host,
        # but caddy terminates TLS in front of it
        ROMM_BASE_URL = "https://${subdomain}.${domain}";
        ROMM_SESSION_SECURE_COOKIE = "true";
        HASHEOUS_API_ENABLED = "true";
        HLTB_API_ENABLED = "true";
        LAUNCHBOX_API_ENABLED = "true";
        ENABLE_SCHEDULED_UPDATE_LAUNCHBOX_METADATA = "true";
        ENABLE_SCHEDULED_RETROACHIEVEMENTS_PROGRESS_SYNC = "true";
      };
    };

    # metadata provider credentials, rendered from .secrets.yaml into an
    # environment file (systemd reads EnvironmentFile as root, so the
    # default template permissions are fine)
    sops = {
      secrets = builtins.listToAttrs (map (name: {
          inherit name;
          value = {};
        }) [
          # keep-sorted start
          "romm-igdb-client-id"
          "romm-igdb-client-secret"
          "romm-retroachievements-api-key"
          "romm-steamgriddb-api-key"
          # keep-sorted end
        ]);

      templates."romm-metadata-env".content = let
        # aliased: binding sops' placeholder directly trips nixf-diagnose
        # (shadows the builtins.placeholder primop)
        secret = config.sops.placeholder;
      in ''
        IGDB_CLIENT_ID=${secret."romm-igdb-client-id"}
        IGDB_CLIENT_SECRET=${secret."romm-igdb-client-secret"}
        RETROACHIEVEMENTS_API_KEY=${secret."romm-retroachievements-api-key"}
        STEAMGRIDDB_API_KEY=${secret."romm-steamgriddb-api-key"}
      '';
    };

    services.romm.environmentFile = config.sops.templates."romm-metadata-env".path;

    # the internal nginx virtual host defaults to listening on :80, which
    # conflicts with caddy; bind it to loopback on our port instead
    services.nginx.virtualHosts."${subdomain}.${domain}".listen = lib.mkForce [
      {
        addr = "127.0.0.1";
        inherit port;
      }
    ];

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
