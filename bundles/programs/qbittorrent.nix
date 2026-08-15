{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "qbittorrent"] {
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.qbittorrent];
  };
}
