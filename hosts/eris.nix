{
  gaia = {
    desktop = "hyprland";
  };

  nixos = {
    programs.firefox.enable = true;

    system.stateVersion = "25.11";
  };

  home-manager = {
    home.stateVersion = "25.11";
  };
}
