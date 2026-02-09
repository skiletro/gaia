{
  erebus = {
    profiles = {
      base.enable = true;
      graphical.enable = true;
      terminal.enable = true;
    };
  };

  homebrew.casks = [
    "dolphin" # more gaming!
    "godot"
    "steam"
  ];

  system.stateVersion = 6; # do not change
}
