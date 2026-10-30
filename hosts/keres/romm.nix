{
  nixos = {
    lib,
    config,
    pkgs,
    ...
  }: let
    subdomain = "romm";
    domain = "warm.vodka";
    dataDir = "/srv/romm";
    port = 8585;
  in {
    # Preserve the deployed account IDs so the container can use the existing
    # library permissions and PostgreSQL's Unix-socket peer authentication.
    users = {
      users.romm = {
        isSystemUser = true;
        uid = 977;
        group = "romm";
        home = dataDir;
      };
      groups.romm.gid = 974;
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["romm"];
      ensureUsers = [
        {
          name = "romm";
          ensureDBOwnership = true;
        }
      ];
    };
    # Keep the socket directory's inode stable for the container bind mount
    # when PostgreSQL restarts.
    systemd.services.postgresql.serviceConfig.RuntimeDirectoryPreserve = "yes";

    systemd.tmpfiles.rules =
      map
      (dir: "d ${dataDir}${dir} 0750 romm romm -")
      ["" "/library" "/resources" "/assets" "/config" "/cache" "/redis"];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.romm = {
        # RomM 5.4.1, matching the native deployment at cutover.
        image = "docker.io/rommapp/romm:5.4.1@sha256:8677fb7b81b1d3db20b849e989a1dadc2a11159e51eb34a2acdcb01102274edf";
        user = "${toString config.users.users.romm.uid}:${toString config.users.groups.romm.gid}";
        ports = ["127.0.0.1:${toString port}:8080"];
        volumes = [
          "${dataDir}:/romm"
          "${dataDir}/redis:/redis-data"
          "/run/postgresql:/run/postgresql:ro"
        ];
        environmentFiles = [
          config.sops.templates."romm-metadata-env".path
          "${dataDir}/.auth-secret.env"
        ];
        environment = {
          ROMM_DB_DRIVER = "postgresql";
          DB_NAME = "romm";
          DB_USER = "romm";
          DB_PORT = "5432";
          # Required by RomM, but unused with peer authentication.
          DB_PASSWD = "peer-auth-unused";
          DB_QUERY_JSON = builtins.toJSON {host = "/run/postgresql";};
          ENABLE_RESCAN_ON_FILESYSTEM_CHANGE = "true";
          ROMM_BASE_URL = "https://${subdomain}.${domain}";
          ROMM_SESSION_SECURE_COOKIE = "true";
          HASHEOUS_API_ENABLED = "true";
          HLTB_API_ENABLED = "true";
          LAUNCHBOX_API_ENABLED = "true";
          ENABLE_SCHEDULED_UPDATE_LAUNCHBOX_METADATA = "true";
          ENABLE_SCHEDULED_RETROACHIEVEMENTS_PROGRESS_SYNC = "true";
        };
      };
    };

    systemd.services.podman-romm = {
      after = ["postgresql.target"];
      requires = ["postgresql.target"];
      unitConfig.RequiresMountsFor = [dataDir "/run/postgresql"];
      preStart = ''
        # Reuse the native service's secret; generate one only on a fresh install.
        if [ ! -s ${dataDir}/.auth-secret.env ]; then
          umask 0077
          printf 'ROMM_AUTH_SECRET_KEY=%s\n' "$(${lib.getExe pkgs.openssl} rand -hex 32)" > ${dataDir}/.auth-secret.env
        fi
      '';
    };

    # Keep provider credentials out of the Nix store and restart on rotation.
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

      templates."romm-metadata-env".restartUnits = ["podman-romm.service"];
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

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
