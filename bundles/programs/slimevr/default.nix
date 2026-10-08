{
  nixos = {pkgs, ...}: let
    package = pkgs.slimevr;
  in {
    environment.systemPackages = [package];

    services.udev.packages = [package];
  };
}
