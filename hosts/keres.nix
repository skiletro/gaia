{ lib, inputs, ... }:
{
  # TODO: figure out a reliable way to deploy to aarm systems from x86
  gaia = {
    programs = {
      # keep-sorted start
      git.enable = true;
      nu.enable = true;
      term-utils.enable = true;
      # keep-sorted end
    };
    state.system = "25.05";
  };

  nixos =
    { modulesPath, config, ... }:
    let
      domain = "warm.vodka";

      deployments = {
        pocket-id = {
          subdomain = "sso";
          port = 1411;
        };
        karakeep = {
          subdomain = "karakeep";
          port = 3001;
        };
        tangled-knot = {
          subdomain = "knot";
          port = 3050;
        };
        wakapi = {
          subdomain = "wakapi"; # TODO: add OIDC
          port = 3009;
        };
        drasl = {
          subdomain = "drasl";
          port = 3002;
        };
      };
    in
    {
      # Secrets
      sops.secrets = {
        "wakapi-env" = {
          owner = "wakapi";
          group = "wakapi";
          mode = "0400";
        };
        "pocketid-encryption-key" = {
          owner = "pocket-id";
          group = "pocket-id";
        };
        "pocketid-drasl-secret" = {
          mode = "444";
        };
        "pocketid-karakeep-secret" = { };
        "pocketid-smtp-pass" = { };
      };

      # Deployments

      services.karakeep = {
        enable = true;
        meilisearch.enable = false; # what is the POINT of stateVersion if it doesn't WORK
        environmentFile = config.sops.templates."karakeep.env".path;
      };

      sops.templates."karakeep.env".content = with deployments.karakeep; ''
        NEXTAUTH_URL="https://${subdomain}.${domain}"
        PORT="${toString port}"
        DISABLE_PASSWORD_AUTH=true
        DISABLE_NEW_RELEASE_CHECK=true

        OAUTH_AUTO_REDIRECT=true
        OAUTH_WELLKNOWN_URL="https://sso.warm.vodka/.well-known/openid-configuration"
        OAUTH_PROVIDER_NAME="Methanol"
        OAUTH_CLIENT_SECRET="${config.sops.placeholder.pocketid-karakeep-secret}"
        OAUTH_CLIENT_ID="f9713737-4a5a-4aed-b221-642b15850415"
      '';

      services.tangled.knot = {
        enable = true;
        gitUser = "git";
        stateDir = "/var/lib/tangled-knot";
        repo.scanPath = "/var/lib/tangled-knot/repos";
        server = with deployments.tangled-knot; {
          listenAddr = "0.0.0.0:${toString port}";
          hostname = "${subdomain}.${domain}";
          owner = "did:plc:bdkgxk7f45l6l7copr3hn3sj"; # @skilet.ro
        };
      };

      services.wakapi = {
        enable = true;
        environmentFiles = [ config.sops.secrets.wakapi-env.path ];
        settings = with deployments.wakapi; {
          server = {
            public_url = "https://${subdomain}.${domain}";
            listen_ipv4 = "127.0.0.1";
            listen_ipv6 = "-";
            inherit port;
          };
          db.dialect = "sqlite3";
          security.allow_signup = false;
          app = {
            aggregation_time = "0 15 2 * * *";
            report_time_weekly = "0 0 18 * * 5";
            data_cleanup_time = "0 0 6 * * 0";
            import_enabled = true;
            leaderboard_enabled = false;
          };
        };
      };

      services.drasl = {
        enable = true;
        settings = with deployments.drasl; {
          Domain = "${subdomain}.${domain}";
          BaseURL = "https://${subdomain}.${domain}";
          InstanceName = "Martini";
          ApplicationOwner = "warm.vodka";
          ListenAddress = "0.0.0.0:${toString port}";
          DefaultAdmins = [ "jamie" ];
          AllowPasswordLogin = false;
          RegistrationOIDC = [
            {
              Name = "Methanol";
              Issuer = "https://sso.warm.vodka";
              ClientID = "9e7a2c41-a937-47c1-bb6b-c100f21e4be9";
              ClientSecretFile = config.sops.secrets.pocketid-drasl-secret.path;
              PKCE = true;
              AllowChoosingPlayerName = true;
            }
          ];
        };
      };

      services.pocket-id = {
        enable = true;
        settings = with deployments.pocket-id; {
          TRUST_PROXY = true;
          ANALYTICS_DISABLED = true;
          APP_URL = "https://${subdomain}.${domain}";

          # UI
          UI_CONFIG_DISABLED = true;
          APP_NAME = "Methanol";
          ALLOW_USER_SIGNUPS = "withToken";
          SMTP_HOST = "smtp.protonmail.ch";
          SMTP_PORT = "587";
          SMTP_USER = "${"noreply"}${"@"}${"warm.vodka"}";
          SMTP_FROM = "${"noreply"}${"@"}${"warm.vodka"}";
          SMTP_TLS = "starttls";
          EMAIL_ONE_TIME_ACCESS_AS_UNAUTHENTICATED_ENABLED = true;
          EMAIL_VERIFICATION_ENABLED = true;
          EMAIL_API_KEY_EXPIRATION_ENABLED = true;
          EMAIL_LOGIN_NOTIFICATION_ENABLED = true;
        };
        credentials = {
          ENCRYPTION_KEY = config.sops.secrets.pocketid-encryption-key.path;
          SMTP_PASSWORD = config.sops.secrets.pocketid-smtp-pass.path;
        };
      };

      # Reverse Proxy
      services.caddy = {
        enable = true;
        virtualHosts = lib.mapAttrs' (
          _name: value:
          (with value; {
            name = "${subdomain}.${domain}";
            value.extraConfig = ''
              reverse_proxy :${toString port}
            '';
          })
        ) deployments;
      };

      # System Stuff
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.disko.nixosModules.default
        inputs.tangled.nixosModules.knot
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      networking.useDHCP = lib.mkDefault true;

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/vda";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  name = "ESP";
                  start = "1M";
                  end = "500M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ]; # Override existing partition
                    mountpoint = "/";
                    mountOptions = [
                      "compress-force=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
}
