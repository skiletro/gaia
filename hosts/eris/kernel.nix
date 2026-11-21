{
  nixos = {pkgs, ...}: {
    boot.kernelPackages = pkgs.linuxPackages;
  };
}
