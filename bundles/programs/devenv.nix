{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "devenv"] {
  home-manager = _: {
    programs.devenv = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
