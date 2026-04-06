{
  nixos =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

      nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

      networking.firewall = {
        allowedTCPPorts = [
          25565
          19132
        ];
        allowedUDPPorts = [
          25565
          19132
        ];
      };

      services.minecraft-servers = {
        enable = true;
        eula = true;
        servers = {

          lauryn = {
            enable = true;
            package = pkgs.fabricServers.fabric-1_21_11;
            serverProperties = {
              white-list = true;
              motd = "bug";
              max-players = 2;
              difficulty = 1;
            };
            whitelist = {
              "Skiletro" = "53133095-f925-4e8d-8512-830cfd319594";
              ".LozP9475" = "00000000-0000-0000-0009-01f88ce64a33";
            };
            operators = {
              "Skiletro" = "53133095-f925-4e8d-8512-830cfd319594";
            };
            symlinks = {
              mods = pkgs.linkFarmFromDrvs "mods" (
                builtins.attrValues {
                  fabric-api = pkgs.fetchurl {
                    name = "fabric-api.jar";
                    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar";
                    sha256 = "1xgfpy6zj1nwwfrhr346firm8zw6lw63pl4parvjwrirc6l57i46";
                  };
                  geyser = pkgs.fetchurl {
                    name = "geyser.jar";
                    url = "https://download.geysermc.org/v2/projects/geyser/versions/2.9.5/builds/1111/downloads/fabric";
                    sha256 = "07dlmr0fl1xspk7yq1k638g6jy349b8jp54d1vylcqkc8zaxj9i9";
                  };
                  floodgate = pkgs.fetchurl {
                    name = "floodgate.jar";
                    url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/wzwExuYr/Floodgate-Fabric-2.2.6-b54.jar";
                    sha256 = "1j776sv7gc8ms5wn5z3y4imm4zsw3dipr2iwll0pcnj9mwrxwmr9";
                  };
                }
              );
            };

          };

        };
      };

    };
}
