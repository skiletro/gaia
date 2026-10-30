{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.bundlix.flakeModules.default];

  bundle = let
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

      iso = {
        system = "x86_64-linux";
        systemPlatform = "nixos";
      };
    };
  in {
    inherit hosts;

    autoImport = {
      enable = true;
      root = ../bundles;
      prefix = ["gaia"];
    };

    users.${user}.hosts =
      lib.mapAttrs (host: attrs: {
        imports = [
          (inputs.import-tree ../core)
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
      })
      hosts;
  };
}
