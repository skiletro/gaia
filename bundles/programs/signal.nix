{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "signal" ] {

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.flare-signal ];
    };

  home-manager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.signal-desktop ];
    };

}
