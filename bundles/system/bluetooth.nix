{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "system" "bluetooth"] {
  nixos = {
    hardware.bluetooth = {
      enable = true;
      disabledPlugins = ["sap"];
      settings.General = {
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
    };

    boot.kernelModules = ["btusb"];
  };
}
