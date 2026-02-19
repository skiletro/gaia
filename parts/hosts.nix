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

        # keres = {
        #   system = "aarch64-linux";
        #   systemPlatform = "nixos";
        # };

        moirai = {
          system = "aarch64-darwin";
          systemPlatform = "darwin";
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
