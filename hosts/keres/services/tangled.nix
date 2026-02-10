{ inputs, config, ... }:
let
  inherit (config.erebus.selfhost) domain;
  subdomain = "tg";
  port = 3050;
in
{
  imports = [ inputs.tangled.nixosModules.knot ];

  services.tangled.knot = {
    enable = true;
    gitUser = "git";
    stateDir = "/var/lib/tangled-knot";
    repo.scanPath = "/var/lib/tangled-knot/repos";
    server = {
      listenAddr = "0.0.0.0:${toString port}";
      hostname = "${subdomain}.${domain}";
      owner = "did:plc:bdkgxk7f45l6l7copr3hn3sj"; # @skilet.ro
    };
  };

  erebus.selfhost.services = {
    ${subdomain} = port;
  };
}
