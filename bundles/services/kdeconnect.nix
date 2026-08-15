{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "services" "kdeconnect"] {
  nixos.programs.kdeconnect.enable = true;
}
