{
  bundleLib,
  inputs,
  inputs',
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "spotify" ] {

  home-manager = {
    imports = [ inputs.spicetify.homeManagerModules.default ];

    programs.spicetify = {
      enable = true;

      enabledExtensions = with inputs'.spicetify.legacyPackages.extensions; [
        songStats
      ];

      enabledCustomApps = with inputs'.spicetify.legacyPackages.apps; [
        newReleases
        lyricsPlus
        ncsVisualizer
      ];
    };
  };

}
