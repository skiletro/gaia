{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "raycast" ] {

  darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.raycast ];
    };

  nixos = throw "gaia: 'raycast' is incompatible with nixos. use 'vicinae' instead.";

}
