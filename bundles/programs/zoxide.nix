{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "zoxide"] {
  home-manager.programs.zoxide.enable = true;
}
