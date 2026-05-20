{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "services" "syncthing" ] {

  gaia.autoStart = [ "syncthingtray --wait" ];

  nixos =
    { pkgs, ... }:
    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        user = "jamie";
        group = "users";
        configDir = "/home/jamie/.config/syncthing";
      };

      environment.systemPackages = [ pkgs.syncthingtray-minimal ];
    };

}
