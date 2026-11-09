{
  inputs,
  lib,
  ...
}: {
  nixos = {
    modulesPath,
    pkgs,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
      inputs.asahix.nixosModules.default
    ];

    hardware.asahi = {
      enable = true;
      extractPeripheralFirmware = true;
      peripheralFirmwareDirectory = pkgs.requireFile {
        name = "vendorfw";
        hashMode = "recursive";
        hash = "sha256-SzAb/GNueE4DKx3FPfgp6QxXjrnT+tocu0Hz6WsUcvI=";
        message = "Please run 'nix-store --add-fixed sha256 --recursive /boot/vendorfw' to add the firmware.";
      };
      # nix hash path --algo sha256 /boot/vendorfw
    };

    users.users.jamie.extraGroups = ["video"];

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S/class/backlight/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S/class/backlight/%k/brightness"
    '';

    networking.networkmanager = {
      enable = lib.mkForce true;
      wifi.backend = lib.mkForce "iwd";
    };

    boot = {
      extraModprobeConfig = ''
        options hid_apple iso_layout=1
      '';
      loader.efi.canTouchEfiVariables = lib.mkForce false;
      initrd = {
        availableKernelModules = ["usb_storage"];
        kernelModules = [];
        luks.devices."crypted".device = "/dev/disk/by-uuid/37cf79ca-1c79-4b61-a9d5-a3f8e2741673";
      };
      kernelPackages = lib.mkForce pkgs.linuxPackages_asahi-fairydust;
      kernelModules = [];
      extraModulePackages = [];
    };

    # cryptsetup luksOpen /dev/nvme0n1p5 cryptroot
    # mount -o subvol=@ /dev/mapper/cryptroot /mnt
    # mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
    # mount -o subvol=@nix /dev/mapper/cryptroot /mnt/nix
    # mount /dev/nvme0n1p4 /mnt/boot
    # nixos-enter
    fileSystems = {
      "/" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = ["subvol=@"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/81C6-1501";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
      "/home" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = ["subvol=@home"];
      };
      "/nix" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = ["subvol=@nix"];
      };
      "/.swapvol" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = ["subvol=@swap"];
      };
    };

    swapDevices = [
      {
        device = "/.swapvol/swapfile";
      }
    ];
  };
}
