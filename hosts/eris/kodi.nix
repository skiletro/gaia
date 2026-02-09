{ pkgs, ... }:
let
  package = pkgs.kodi-gbm.withPackages (
    p: with p; [
      jellyfin
      pvr-iptvsimple
    ]
  );
in
{
  services.xserver.desktopManager.kodi = {
    enable = true;
    inherit package;
  };
}
