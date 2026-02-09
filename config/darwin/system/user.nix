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
    system.primaryUser = "jamie";

    users.users.jamie = {
      name = "jamie";
      home = "/Users/jamie";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcAzqMv0//j1mUVb/NBUiMgv2brdPv9HbNs83OkQZzq moirai"
      ];
    };

    programs.zsh.interactiveShellInit = ''
      if [[ $TERM != "dumb" && -z $ZSH_EXECUTION_STRING ]]; then
        exec ${lib.getExe pkgs.nushell} --config ~/.config/nushell/config.nu
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
      users.jamie = {
        home.stateVersion = "25.11";
        imports = [
          self.homeModules.erebus
          self.homeModules.autostart
        ];
      };
    };
  };
}
