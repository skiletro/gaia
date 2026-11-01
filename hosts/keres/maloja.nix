{self', ...}: {
  nixos = {config, ...}: let
    subdomain = "maloja";
    domain = "warm.vodka";
    dataDir = "/srv/maloja";
    port = 42010;
    image = self'.sources.maloja.src;
  in {
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0700 root root -"
      "d ${dataDir}/data 0700 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.maloja = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        pull = "never";
        ports = ["127.0.0.1:${toString port}:${toString port}"];
        volumes = ["${dataDir}/data:/mljdata"];
        environmentFiles = [config.sops.templates."maloja-admin-env".path];
        environment = {
          MALOJA_DATA_DIRECTORY = "/mljdata";
          MALOJA_SKIP_SETUP = "true";
          MALOJA_HOST = "0.0.0.0";
          MALOJA_LOCATION_TIMEZONE = config.time.timeZone;
          MALOJA_PORT = toString port;
        };
      };
    };

    systemd.services.podman-maloja.unitConfig.RequiresMountsFor = [dataDir];

    sops = {
      secrets."maloja-admin-password" = {};
      templates."maloja-admin-env" = {
        restartUnits = ["podman-maloja.service"];
        content = let
          secret = config.sops.placeholder;
        in ''
          MALOJA_FORCE_PASSWORD=${secret."maloja-admin-password"}
        '';
      };
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}
