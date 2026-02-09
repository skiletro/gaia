{
  lib,
  config,
  pkgs,
  pkgs',
  ...
}:
{
  options.erebus.profiles.graphical.enable =
    lib.mkEnableOption "graphical applications that are generally wanted on non-headless systems";

  config = lib.mkIf config.erebus.profiles.graphical.enable {
    erebus = {
      services = {
        aerospace.enable = true; # wm
        jankyborders.enable = true; # borders
        raycast.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start ignore_prefixes=pkgs'.
      betterdisplay
      grandperspective # disk usage visualiser
      iina # media player
      m-cli
      pkgs'.pearcleaner-bin
      utm
      # keep-sorted end
    ];

    homebrew.masApps.Xcode = 497799835;

    home-manager.sharedModules = lib.singleton {
      erebus.profiles.graphical.enable = true;
    };
  };
}
