let
  subdomain = "navidrome";
  domain = "warm.vodka";
  port = 4533;

  RootFolder = "/srv/navidrome";
  MusicFolder = "${RootFolder}/music";
  DataFolder = "${RootFolder}/data";
  CacheFolder = "${RootFolder}/cache";
in {
  nixos = {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = port;
        DefaultTheme = "Spotify-ish";
        inherit MusicFolder DataFolder CacheFolder;
        EnableSharing = false;
        EnableStarRating = false;
      };
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';

    users.users.jamie.extraGroups = ["navidrome"];
  };

  home-manager = {
    programs.beets = {
      enable = true;
      settings = {
        library = MusicFolder;

        plugins = [
          # keep-sorted start
          "badfiles"
          "duplicates"
          "fetchart"
          "lastgenre"
          "lyrics"
          "musicbrainz"
          "spotify"
          "zero"
          # keep-sorted end
        ];

        fetchart = {
          sources = "coverart itunes amazon albumart filesystem";
          cautious = true;
          store_source = true;
          minwidth = 1200;
          maxwidth = 1200;
        };

        lyrics = {
          # synced works incorrectly, so the order is important (lrclib is the only one that offers synced lyrics)
          sources = [
            "lrclib"
            "genius"
            "tekstowo"
            "google"
          ];
          synced = true;
          force = true;
        };

        spotify = {
          show_failures = true;
        };

        zero.fields = "comments";
      };
    };
  };
}
