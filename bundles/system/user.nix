{
  nixos =
    { config, ... }:
    {
      sops.secrets."jamie-password".neededForUsers = true;

      users = {
        mutableUsers = false; # forces declaration of user and group adding and modification
        users.jamie = {
          isNormalUser = true;
          # hashedPasswordFile = config.sops.secrets.jamie-password.path;
          password = "123"; # TODO: REMOVE ME!!!!!!!!!!!!
          extraGroups = [
            "users"
            "networkmanager"
            "wheel"
            "libvirtd"
            "gamemode"
            "docker"
            "kvm"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcAzqMv0//j1mUVb/NBUiMgv2brdPv9HbNs83OkQZzq moirai"
          ];
        };
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };

  home-manager = {

    home = {
      username = "jamie";
      homeDirectory = "/home/jamie";
    };
  };
}
