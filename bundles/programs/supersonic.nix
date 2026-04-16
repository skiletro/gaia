{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "supersonic" ] {

  home-manager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.supersonic ];
    };

}
