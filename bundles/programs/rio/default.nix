{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rio"] {
  home-manager = {pkgs, ...}: {
    programs.rio = {
      enable = true;
      # Patched to only show the quit confirmation when a foreground process
      # other than the shell is running in any tab or split. Upstream keeps
      # `confirm-before-quit` as a plain boolean (rio issue #1036).
      package = pkgs.rio.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./confirm-quit.patch];
      });
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
