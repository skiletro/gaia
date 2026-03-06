{ lib, inputs, ... }:
{
  nixos =
    { modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.disko.nixosModules.default
      ];

      boot = {
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "virtio_pci"
            "virtio_scsi"
            "usbhid"
            "sr_mod"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      networking = {
        useDHCP = lib.mkDefault true;
        firewall.allowedTCPPorts = [
          80
          443
        ];
      };

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
