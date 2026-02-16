{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "system" "bluetooth" ] {

  nixos = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

}
