let
  username = "jamie";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcAzqMv0//j1mUVb/NBUiMgv2brdPv9HbNs83OkQZzq moirai"
  ];
in
{
  nixos = _: {
    sops.secrets."jamie-password".neededForUsers = true;

    users = {
      mutableUsers = false; # forces declaration of user and group adding and modification
      users.${username} = {
        isNormalUser = true;
        # hashedPasswordFile = config.sops.secrets.jamie-password.path;
        password = "123"; # TODO: REMOVE ME!!!!!!!!!!!!
        extraGroups = [
          # TODO: probably get rid of some of these
          "users"
          "networkmanager"
          "wheel"
          "libvirtd"
          "gamemode"
          "docker"
          "kvm"
        ];
        openssh.authorizedKeys.keys = sshKeys;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  home-manager =
    { pkgs, ... }:
    {
      home = {
        inherit username;
        homeDirectory =
          let
            homeDir = if pkgs.stdenvNoCC.hostPlatform.isDarwin then "Users" else "home";
          in
          "/${homeDir}/${username}";
      };
    };

  darwin = {
    system.primaryUser = username;

    users.users.${username} = {
      name = username;
      home = "/Users/${username}";
      openssh.authorizedKeys.keys = sshKeys;
    };
  };
}
