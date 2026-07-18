{ inputs, lib, ... }:
{
  imports = [ inputs.bundle.flakeModules.default ];

  bundle =
    let
      user = "jamie";

      hosts = {
        eris = {
          system = "x86_64-linux";
          systemPlatform = "nixos";
        };

        keres = {
          system = "aarch64-linux";
          systemPlatform = "nixos";
        };

        moirai = {
          system = "aarch64-linux";
          systemPlatform = "nixos";
        };

        hemera = {
          system = "x86_64-linux";
          systemPlatform = "nixos";
        };

        iso = {
          system = "x86_64-linux";
          systemPlatform = "nixos";
        };
      };
    in
    {
      inherit hosts;

      users.${user}.hosts = lib.mapAttrs (host: attrs: {
        imports = [
          (inputs.import-tree ../bundles)
          (inputs.import-tree ../hosts/${host})
          {
            ${attrs.systemPlatform} = {
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
