{
  config,
  lib,
  inputs,
  inputs',
  self,
  self',
  pkgs,
  pkgs',
  ...
}:
{
  options.erebus.system.user.enable = lib.mkEnableOption "Jamie user";

  config = lib.mkIf config.erebus.system.user.enable {
    sops.secrets."user-password".neededForUsers = true;

    users = {
      mutableUsers = false; # forces declaration of user and group adding and modification
      users.jamie = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.user-password.path;
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

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    programs.fish.enable = true; # For autocompletions. We will use the home manager module for configuration.
    programs.bash.interactiveShellInit = ''
      if [ "$TERM" != "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ] && [ "$SHLVL" == "1" ]; then
        exec ${lib.getExe pkgs.nushell}
      fi
    '';

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit
          inputs
          inputs'
          self
          self'
          pkgs'
          ;
      };
      users.jamie.imports = [
        self.homeModules.erebus
        self.homeModules.autostart
        {
          home = {
            username = "jamie";
            homeDirectory = "/home/jamie";
            stateVersion = "25.05";
          };
        }
      ];
    };
  };
}
