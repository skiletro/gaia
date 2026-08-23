{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rio"] {
  home-manager = {
    programs.rio = {
      enable = true;
      settings = {
        padding = [24];
        cursor.shape = "beam";
      };
    };
  };
}
