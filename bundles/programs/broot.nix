{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "broot" ] {

  home-manager = {
    programs.broot.enable = true;
  };

}
