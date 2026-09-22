{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "zellij"] {
  home-manager.programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
      show_startup_tips = false;
      default_shell = "nu";
      scrollback_editor = "hx";
    };
  };
}
