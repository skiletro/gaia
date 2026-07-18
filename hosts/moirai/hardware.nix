{
  inputs,
  lib,
  ...
}:
{
  nixos = { modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    ];

    hardware.asahi.enable = true;

    services.xserver.xkbOptions = "ctrl:nocaps"; # use capslock as ctrl
    console.useXkbConfig = true;

    networking.networkmanager = {
      enable = lib.mkForce true;
      wifi.backend = lib.mkForce "iwd";
    };

    boot = {
      extraModprobeConfig = ''
        options hid_apple iso_layout=1
      '';
      loader = {
        systemd-boot.enable = lib.mkForce true;
        limine.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
      };
      initrd = {
        availableKernelModules = [ "usb_storage" ];
        kernelModules = [ ];
        luks.devices."crypted".device = "/dev/disk/by-uuid/37cf79ca-1c79-4b61-a9d5-a3f8e2741673";
      };
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [ "subvol=@" ];
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
        options = [ "subvol=@home" ];
      };
      "/nix" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };
      "/.swapvol" = {
        device = "/dev/mapper/crypted";
        fsType = "btrfs";
        options = [ "subvol=@swap" ];
      };
    };

    swapDevices = [
      {
        device = "/.swapvol/swapfile";
      }
    ];

  };

}
