{ bundleLib, self', ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "proton" ] {

  home-manager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.protonmail-desktop
        self'.packages.protonvpn-bin
        self'.packages.protonpass-bin
      ];
    };

}
