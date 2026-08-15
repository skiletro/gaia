{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "libreoffice"] {
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.libreoffice];
  };
}
