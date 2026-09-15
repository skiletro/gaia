{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "wine"] {
  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      wineWow64Packages.stable
      winetricks
    ];
  };
}
