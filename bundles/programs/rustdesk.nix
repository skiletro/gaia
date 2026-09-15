{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rustdesk"] {
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.rustdesk-flutter];
  };
}
