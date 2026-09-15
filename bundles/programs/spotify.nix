{
  bundleLib,
  lib,
  inputs,
  inputs',
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "spotify"] {
  home-manager = {pkgs, ...}: {
    imports = [inputs.spicetify.homeManagerModules.default];

    programs.spicetify = {
      enable = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isx86 true;

      enabledExtensions = with inputs'.spicetify.legacyPackages.extensions; [
        songStats
      ];

      enabledCustomApps = with inputs'.spicetify.legacyPackages.apps; [
        newReleases
        lyricsPlus
        ncsVisualizer
      ];
    };

    home.packages = [pkgs.spotatui];
  };
}
