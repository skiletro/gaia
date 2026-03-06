{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "signal" ] {

  home-manager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.signal-desktop ];
    };

}
