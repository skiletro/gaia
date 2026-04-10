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

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';
    };
}
