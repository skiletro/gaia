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
        karakeep = {
          subdomain = "kk";
          port = 3001;
        };
        tangled = {
          subdomain = "tk";
          port = 3050;
        };
        wakapi = {
          subdomain = "wt";
          port = 3009;
        };
      };
    in
    {
      # Deployments
      sops.secrets."wakapi-env" = {
        owner = "wakapi";
        group = "wakapi";
        mode = "0400";
      };

      services.karakeep = {
        enable = true;
        meilisearch.enable = false; # what is the POINT of stateVersion if it doesn't WORK
        extraEnvironment = with deployments.karakeep; {
          NEXTAUTH_URL = "https://${subdomain}.${domain}";
          PORT = toString port;
          DISABLE_SIGNUPS = "true";
          DISABLE_NEW_RELEASE_CHECK = "true";
        };
      };

      services.tangled.knot = {
        enable = true;
        gitUser = "git";
        stateDir = "/var/lib/tangled-knot";
        repo.scanPath = "/var/lib/tangled-knot/repos";
        server = with deployments.tangled; {
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
