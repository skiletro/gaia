{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "rustdesk"] {
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.rustdesk-flutter];
  };
}
