{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "services" "kdeconnect" ] {

  nixos.programs.kdeconnect.enable = true;

  darwin = throw "gaia: kde connect is incompatible with macos.";

}
