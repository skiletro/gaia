{ config, pkgs, ... }:
let
  subdomain = "cw";
  port = 3010;

  calibreLibrary = "/var/lib/calibre";
in
{
  services.calibre-web = {
    enable = true;
    listen = {
      ip = "127.0.0.1";
      inherit port;
    };
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
      enableKepubify = true;
      inherit calibreLibrary;
    };
  };

  systemd.services.calibre-web-init-db = {
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "60";
    };
    wantedBy = [ "multi-user.target" ];
    before = [ "calibre-web.service" ];

    script =
      let
        emptyMetadataDB = pkgs.fetchurl {
          url = "https://github.com/janeczku/calibre-web/raw/refs/tags/0.6.23/library/metadata.db";
          hash = "sha256-+sL34370vA+ylV6aP2EmBHB9TvVzr1wovXqDaTOfS9Q=";
        };
        cfg = config.services.calibre-web;
      in
      # sh
      ''
        set -euo pipefail
        if [ ! -f ${calibreLibrary}/metadata.db ]; then
          install -Dm666 ${emptyMetadataDB} ${calibreLibrary}/metadata.db
          chown -R ${cfg.user}:${cfg.group} ${calibreLibrary}
        fi
      '';
  };

  erebus.selfhost.services.${subdomain} = port;
}
