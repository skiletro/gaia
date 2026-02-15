{ self', ... }:
{
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
