{
  gaia = {
    desktop = "niri";
    system = {
      # keep-sorted start
      bluetooth.enable = true;
      fonts.enable = true;
      greeter.enable = true;
      # keep-sorted end
    };
    services = {
      # keep-sorted start
      flatpak.enable = true;
      printing.enable = true;
      wireguard.enable = true;
      # keep-sorted end
    };
    programs = {
      # keep-sorted start
      btop.enable = true;
      devenv.enable = true;
      git.enable = true;
      helium.enable = true;
      helix.enable = true;
      nu.enable = true;
      signal.enable = true;
      term-utils.enable = true;
      zoxide.enable = true;
      # keep-sorted end
    };
    state.system = "26.11";
  };
}
