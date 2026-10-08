{
  gaia = {
    device.type = "installer";
    programs = {
      # keep-sorted start
      git.enable = true;
      nu.enable = true;
      starship.enable = true;
      # keep-sorted end
    };
    state.system = "26.05";
  };
}
