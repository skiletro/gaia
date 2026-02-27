{ inputs, lib, ... }:
{
  gaia = {
    programs = {
      nu.enable = true;
      git.enable = true;
      term-utils.enable = true;
    };
    state.system = "26.05";
  };

  nixos =
    { pkgs, ... }:
    {
      imports = [
        inputs.disko.nixosModules.default
      ];

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_zen;

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };

      services.tlp.enable = true;

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/nvme0n1";
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
