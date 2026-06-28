{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "opencode" ] {

  home-manager.programs.opencode.enable = true;

}
