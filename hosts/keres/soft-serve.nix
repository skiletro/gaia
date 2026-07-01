{ lib, ... }:
let
  subdomain = "git";
  domain = "warm.vodka";
  httpPort = 23232;
  sshPort = 2200;
in
{
  nixos = {
    users.users.soft-serve = {
      isSystemUser = true;
      group = "soft-serve";
      home = "/srv/git";
    };
    users.groups.soft-serve = { };

    systemd.tmpfiles.rules = [
      "d /srv/git 0750 soft-serve soft-serve - -"
    ];

    services.soft-serve = {
      enable = true;
      settings = {
        name = "Vodka Float";
        log_format = "text";
        http = {
          listen_addr = "127.0.0.1:${toString httpPort}";
          public_url = "https://${subdomain}.${domain}";
          cors.allowed_origins = [ "https://${subdomain}.${domain}" ];
        };
        git.listen_addr = "127.0.0.1:9418";
        ssh = {
          listen_addr = ":${toString sshPort}";
          public_url = "ssh://${subdomain}.${domain}";
        };
        initial_admin_keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
        ];
      };
    };

    systemd.services.soft-serve = {
      serviceConfig.PrivateMounts = lib.mkForce false;
      serviceConfig.PrivateUsers = lib.mkForce false;
      serviceConfig.DynamicUser = lib.mkForce false;
      serviceConfig.User = lib.mkForce "soft-serve";
      serviceConfig.Group = lib.mkForce "soft-serve";
      serviceConfig.StateDirectory = lib.mkForce "";
      serviceConfig.WorkingDirectory = lib.mkForce "/srv/git";
      serviceConfig.ExecPaths = lib.mkForce "/srv/git";
      environment.SOFT_SERVE_DATA_PATH = lib.mkForce "/srv/git";
      serviceConfig.CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
      serviceConfig.AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString httpPort}
    '';

    networking.firewall.allowedTCPPorts = [ sshPort ];
  };
}
