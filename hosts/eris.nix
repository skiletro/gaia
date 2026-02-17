{ inputs, lib, ... }:
{
  gaia = {
    desktop = "hyprland";
    system = {
      bluetooth.enable = true;
    };
    services = {
      # keep-sorted start
      # keep-sorted end
    };
    programs = {
      # keep-sorted start
      beets.enable = true;
      broot.enable = true;
      btop.enable = true;
      direnv.enable = true;
      discord.enable = true;
      gamemode.enable = true;
      git.enable = true;
      gsr.enable = true;
      helium.enable = true;
      helix.enable = true;
      kitty.enable = true;
      libreoffice.enable = true;
      nu.enable = true;
      proton.enable = true;
      spotify.enable = true;
      steam.enable = true;
      wivrn.enable = true;
      zed.enable = true;
      # keep-sorted end
    };
    state.system = "25.11";
  };

  nixos = {
    imports = with inputs.nixos-hardware.nixosModules; [
      # keep-sorted start
      common-cpu-amd
      common-cpu-amd-pstate
      common-cpu-amd-zenpower
      common-gpu-amd
      common-pc-ssd
      # keep-sorted end
    ];

    # Boot Hardware
    boot.initrd.availableKernelModules = [
      # keep-sorted start
      "ahci"
      "nvme"
      "sd_mod"
      "usb_storage"
      "usbhid"
      "xhci_pci"
      # keep-sorted end
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
    boot.supportedFilesystems = [ "ntfs" ];

    # Drives
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/94e933e3-aaf9-4cf3-b7c9-044306fce269";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F4AF-09F7";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = lib.singleton { device = "/dev/disk/by-uuid/ae2dc9bc-8451-48f4-a42b-916e449f30b8"; };

    hardware = {
      enableRedistributableFirmware = true;
      amdgpu.overdrive.enable = true;
    };

  };
}
