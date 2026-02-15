{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "direnv" ] {

  home-manager = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # faster impl.
      silent = true; # hides spam w/ a bunch of variables
    };
  };

}
