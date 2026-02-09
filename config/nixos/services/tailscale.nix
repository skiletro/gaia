{ config, lib, ... }:
{
  options.erebus.services.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.erebus.services.tailscale.enable {
    services.tailscale.enable = true;

    home-manager.sharedModules = lib.mkIf config.erebus.profiles.graphical.enable [
      (userAttrs: {
        xdg.autostart.entries = userAttrs.config.lib.erebus.autostartEntry "Trayscale" "${lib.getExe config.services.tailscale.package} --hide-window";
      })
    ];
  };
}
