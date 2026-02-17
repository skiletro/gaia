{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "services" "flatpak" ] {

  # Flatpak programs are to be used for games only
  nixos =
    { pkgs, ... }:
    {
      services.flatpak.enable = true;

      environment.systemPackages = [ pkgs.bazaar ];
    };

  darwin = throw "gaia: 'flatpak' is incompatible with macos.";

}
