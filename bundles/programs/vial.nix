{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "vial"] {
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.vial];

    services.udev.packages = with pkgs; [
      via
      vial
      qmk-udev-rules
    ];
  };
}
