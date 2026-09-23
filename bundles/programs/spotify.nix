{
  bundleLib,
  inputs,
  inputs',
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "spotify"] {
  home-manager = {pkgs, ...}: {
    imports = [inputs.spicetify.homeManagerModules.default];

    programs.spicetify = {
      enable =
        if pkgs.stdenvNoCC.hostPlatform.isx86
        then true
        else throw "gaia: spotify is x86 only :(";

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
