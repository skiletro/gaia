{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "gsr" ] {

  nixos.programs'.gpu-screen-recorder-ui.enable = true;

  darwin = throw "gaia: 'gsr' is incompatible with macos.";

}
