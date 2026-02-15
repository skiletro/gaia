{
  home-manager = {
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
