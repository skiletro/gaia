{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "lsfg" ] {

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        lsfg-vk
        lsfg-vk-ui
      ];
    };

  darwin = throw "gaia: 'lsfg' is incompatible with macos.";

}
