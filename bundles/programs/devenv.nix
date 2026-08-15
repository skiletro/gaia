{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "devenv"] {
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.devenv];
  };
}
