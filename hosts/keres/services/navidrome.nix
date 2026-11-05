# Service: Navidrome
# Dependencies: Caddy
# Data location:
#   Private application state: /var/lib/navidrome
#   Music library: /var/lib/navidrome/music
#   Cache: /var/cache/navidrome
#   Beets library database: /home/jamie/.local/share/beets/library.db
let
  subdomain = "navidrome";
  port = 4533;

  DataFolder = "/var/lib/navidrome";
  MusicFolder = "${DataFolder}/music";
  CacheFolder = "/var/cache/navidrome";
in {
  nixos = {
    lib,
    mkCaddyProxy,
    ...
  }: {
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

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;

    # Grant traversal of private state, but group write access only to music.
    systemd.tmpfiles.settings.navidromeDirs = {
      "${DataFolder}".d.mode = lib.mkForce "0710";
      "${MusicFolder}".d = {
        mode = lib.mkForce "2770";
        user = lib.mkForce "navidrome";
        group = lib.mkForce "navidrome";
      };
    };
    systemd.services.navidrome.serviceConfig = {
      StateDirectoryMode = "0710";
      UMask = lib.mkForce "0077";
    };

    users.users.jamie.extraGroups = ["navidrome"];
  };

  home-manager = {config, ...}: {
    programs.beets = {
      enable = false;
      settings = {
        # library is the beets database file, not the music location
        library = "${config.xdg.dataHome}/beets/library.db";
        directory = MusicFolder;

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
          sources = [
            "coverart"
            "itunes"
            "amazon"
            "albumart"
            "filesystem"
          ];
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
