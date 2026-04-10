{ self', ... }:
{
  nixos =
    let
      subdomain = "navidrome";
      domain = "warm.vodka";
      port = 4533;
    in
    {
      services.navidrome = {
        enable = true;
        settings = {
          Address = "127.0.0.1";
          Port = port;
          MusicFolder = "/mnt/music";
          EnableSharing = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d /mnt/music 0770 navidrome navidrome -"
      ];

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';

      environment.systemPackages = [ self'.packages.spotiflac-cli ];
    };
}
