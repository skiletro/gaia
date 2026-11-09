# Service: Maloja
# Dependencies: Podman, Caddy, sops-nix
# Data location:
#   Application state (/mljdata in the container): /var/lib/maloja
{self', ...}: {
  nixos = {
    config,
    mkCaddyProxy,
    ...
  }: let
    subdomain = "maloja";
    dataDir = "/var/lib/maloja";
    port = 42010;
    image = self'.sources.maloja.src;
  in {
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0700 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.maloja = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        pull = "never";
        ports = ["127.0.0.1:${toString port}:${toString port}"];
        volumes = ["${dataDir}:/mljdata"];
        environmentFiles = [config.sops.secrets."maloja-env".path];
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

    sops.secrets."maloja-env".restartUnits = ["podman-maloja.service"];

    services.caddy.virtualHosts = mkCaddyProxy subdomain port;
  };
}
