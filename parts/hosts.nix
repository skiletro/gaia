{ inputs, lib, ... }:
{
  imports = [ inputs.bundle.flakeModules.default ];

  bundle =
    let
      user = "jamie";

      hosts = {
        eris = {
          system = "x86_64-linux";
          class = "nixos";
        };

        keres = {
          system = "aarch64-linux";
          class = "nixos";
        };

        moirai = {
          system = "aarch64-darwin";
          class = "darwin";
        };
      };
    in
    {
      inherit hosts;

      users.${user}.hosts = lib.mapAttrs (host: attrs: {
        imports = [
          (inputs.import-tree ../bundles)
          ../hosts/${host}.nix
          {
            ${attrs.class} = {
              nixpkgs.hostPlatform = attrs.system;
              networking.hostName = host;
            };

            home-manager = {
              home.username = "jamie";
            };
          }
        ];
      }) hosts;
    };

}
