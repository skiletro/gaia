{
  gaia = {
    programs = {
      # keep-sorted start
      git.enable = true;
      nu.enable = true;
      term-utils.enable = true;
      # keep-sorted end
    };
    state.system = "26.05";
  };

  nixos =
    { modulesPath, ... }:
    {
      system.switch.enable = false;

      imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix") ];
    };
}
