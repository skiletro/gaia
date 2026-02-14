{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "rider" ] {

  home-manager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jetbrains.rider
        dotnet-sdk_10
      ];
    };

}
