{ self', ... }:
{
  nixos =
    { pkgs, ... }:
    let
      subdomain = "navidrome";
      domain = "warm.vodka";
      port = 4533;

      rootFolder = "/srv/navidrome";
    in
    {
      services.navidrome = {
        enable = true;
        settings = {
          Address = "127.0.0.1";
          Port = port;
          MusicFolder = "${rootFolder}/music";
          DataFolder = "${rootFolder}/data";
          CacheFolder = "${rootFolder}/cache";
          DefaultTheme = "Spotify-ish";
          EnableSharing = false;
          EnableStarRating = false;
        };
      };

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';

      environment.systemPackages = [
        self'.packages.spotiflac-cli
        pkgs.beets
      ];
    };
}
