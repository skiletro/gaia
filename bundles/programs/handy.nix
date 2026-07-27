{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "handy" ] {

  gaia.autoStart = [ "handy --start-hidden" ];

  nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      handy
      wtype
    ];
  };

}
