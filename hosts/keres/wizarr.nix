{
  nixos = {
    # wizarr has no nixos module or nixpkgs package; run the upstream
    # multi-arch (arm64 confirmed) container instead.
    virtualisation = {
      podman.enable = true;

      oci-containers = {
        backend = "podman";

        containers.wizarr = {
          image = "ghcr.io/wizarrrr/wizarr:latest";
          ports = ["127.0.0.1:5690:5690"];
          volumes = [
            "/srv/wizarr:/data"
            # Navidrome's Subsonic API stubs user management with 501, so
            # this patched client uses Navidrome's native API for users.
            # TODO: drop once upstream wizarr fixes navidrome.py.
            "${./wizarr-navidrome.py}:/app/app/services/media/navidrome.py:ro"
          ];
          environment = {
            TZ = "Europe/London";
          };
        };
      };
    };

    services.caddy.virtualHosts."wizarr.warm.vodka".extraConfig = ''
      reverse_proxy 127.0.0.1:5690
    '';

    systemd.tmpfiles.rules = [
      "d /srv/wizarr 0755 root root -"
    ];
  };
}
