{
  # Flatpak programs are to be used for games only
  nixos = {pkgs, ...}: {
    services.flatpak.enable = true;

    environment.systemPackages = [pkgs.bazaar];
  };

  home-manager.stylix.targets.gtk.flatpakSupport.enable = true;
}
