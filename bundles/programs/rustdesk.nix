{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "rustdesk" ] {

  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.rustdesk-flutter ];
    };

  darwin = {
    homebrew.casks = lib.singleton "rustdesk";
  };

}
