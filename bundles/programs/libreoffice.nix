{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "libreoffice"] {
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.libreoffice];
  };
}
