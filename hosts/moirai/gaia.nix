{
  gaia = {
    desktop = "hyprland";
    system = {
      bluetooth.enable = true;
      fonts.enable = true;
      greeter.enable = true;
    };
    services = {
      flatpak.enable = true;
      printing.enable = true;
      wireguard.enable = true;
    };
    programs = {
      btop.enable = true;
      devenv.enable = true;
      git.enable = true;
      helium.enable = true;
      helix.enable = true;
      nu.enable = true;
      term-utils.enable = true;
      zoxide.enable = true;
    };
    state.system = "26.11";
  };
}
