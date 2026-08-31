{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rio"] {
  home-manager = {
    programs.rio = {
      enable = true;
      settings = {
        padding = [48];
        cursor.shape = "beam";
        line-height = 1.2;
        navigation = {
          mode = "Plain";
          use-split = false;
        };
      };
    };
  };
}
