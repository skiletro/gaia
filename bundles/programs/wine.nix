{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "wine" ] {

  nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wineWow64Packages.stable
      winetricks
    ];
  };

}
