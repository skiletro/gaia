{ inputs, ... }:
{
  nixos =
    let
      subdomain = "knot";
      domain = "warm.vodka";
      port = 3050;
    in
    {
      imports = [
        inputs.tangled.nixosModules.knot
      ];

      services.tangled.knot = {
        enable = true;
        gitUser = "git";
        stateDir = "/srv/tangled/knot";
        repo.scanPath = "/srv/tangled/knot/repos";
        server = {
          listenAddr = "0.0.0.0:${toString port}";
          hostname = "${subdomain}.${domain}";
          owner = "did:plc:bdkgxk7f45l6l7copr3hn3sj"; # @skilet.ro
        };
      };

      services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
        reverse_proxy :${toString port}
      '';
    };
}
