{
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.qbittorrent];
  };
}
