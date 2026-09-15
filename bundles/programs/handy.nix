{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "handy"] {
  gaia.autoStart = ["handy --start-hidden"];

  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      handy
      wtype
    ];
  };
}
