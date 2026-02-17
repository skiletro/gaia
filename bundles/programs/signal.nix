{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "signal" ] {

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.signal-desktop ];
    };

  darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.signal-desktop-bin ];
    };

}
