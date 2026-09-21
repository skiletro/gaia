{
  gaia = {
    services.tailscale.enable = true;
    programs = {
      # keep-sorted start
      git.enable = true;
      nu.enable = true;
      # keep-sorted end
    };
    state.system = "25.05";
  };
}
