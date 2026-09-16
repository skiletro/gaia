{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rio"] {
  home-manager = {
    programs.rio = {
      enable = true;
      settings = {
        line-height = 1.2;
        navigation = {
          mode = "Plain";
          use-split = false;
        };
      };
    };
  };
}
