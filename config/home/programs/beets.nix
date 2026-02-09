{
  lib,
  config,
  ...
}:
{
  options.erebus.programs.beets.enable = lib.mkEnableOption "Beets, the music library manager";

  config = lib.mkIf config.erebus.programs.beets.enable {
    programs.beets = {
      enable = true;
      settings = {
        directory = "~/Music";
        library = "~/Music/beets.db";
        "import".move = true;
        plugins = [
          "fetchart"
          "lyrics"
          "lastgenre"
          "musicbrainz"
          "spotify"
        ];
      };
    };
  };
}
