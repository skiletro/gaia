{
  nixos =
    { pkgs, ... }:
    {
      services.minecraft-server = {
        enable = true;
        eula = true;
        openFirewall = true;
        package = pkgs.minecraftServers.vanilla-1-2.override {
          url = "https://github.com/Better-than-Adventure/bta-download-repo/releases/download/v7.3_04/bta.v7.3_04.server.jar";
          sha1 = "sha1-FRFekkiYl3HVS8WIMDSH6jBiZKE=";
        };
      };
    };
}
