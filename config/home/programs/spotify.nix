{
  inputs,
  inputs',
  lib,
  config,
  ...
}:
{
  imports = [ inputs.spicetify.homeManagerModules.default ];

  options.erebus.programs.spotify.enable = lib.mkEnableOption "Spotify and Spicetify addons";

  config = lib.mkIf config.erebus.programs.spotify.enable {
    programs.spicetify =
      let
        inherit (inputs'.spicetify.legacyPackages) extensions apps;
      in
      {
        enable = true;

        enabledExtensions = with extensions; [
          songStats
        ];

        enabledCustomApps = with apps; [
          newReleases
          lyricsPlus
          ncsVisualizer
        ];
      };
  };
}
