{lib, ...}: {
  nixos = {pkgs, ...}: {
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

      loader = {
        limine.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
