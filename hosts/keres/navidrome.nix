{ self', lib, ... }:
{
  nixos =
    { pkgs, ... }:
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
          UIWelcomeMessage = "Hi! Please use a dedicated Desktop/Mobile app instead of this frontend.";
          Plugins.Enabled = true;
          Agents = "deezer,audiomuseai";
        };
      };

      systemd.services.navidrome.serviceConfig.ExecStartPre =
        let
          audiomuseai = pkgs.fetchurl {
            url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/download/v7/audiomuseai.ndp";
            sha256 = "1y23vb5kip1gzd0i1c7lr4dwamyn8irzql5y0zhz17gbqf1w5dzs";
          };
        in
        [
          "${lib.getExe' pkgs.coreutils "mkdir"} -p /var/lib/navidrome/plugins"
          "${lib.getExe' pkgs.coreutils "cp"} -f ${audiomuseai} /var/lib/navidrome/plugins/audiomuseai.ndp"
        ];

      systemd.tmpfiles.rules = [
        "d /mnt/music 0770 navidrome navidrome -"
      ];

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';

      environment.systemPackages = [ self'.packages.spotiflac-cli ];
    };
}
