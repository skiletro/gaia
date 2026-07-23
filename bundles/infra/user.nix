let
  username = "jamie";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
  ];
in
{
  nixos = {
    users = {
      mutableUsers = false; # forces declaration of user and group adding and modification
      users.${username} = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$hyPw7ecQ4UMGe5ArOW0bD/$3Oz3yxROROz1eU9u3DiGB5y8a7g4mD/E3AIOx2Pm8x0";
        extraGroups = [
          "users" # default user group for users
          "wheel" # sudo
        ];
        openssh.authorizedKeys.keys = sshKeys;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  home-manager =
    { config, ... }:
    {
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        preferXdgDirectories = true;
        # Try and clean up our home/ directory as much as possible.
        sessionVariables = with config.xdg; {
          # keep-sorted start
          ANDROID_AVD_HOME = "${dataHome}/android/avd";
          ANDROID_USER_HOME = "${dataHome}/android";
          BUN_INSTALL_GLOBAL_DIR = "${dataHome}/bun";
          CARGO_HOME = "${dataHome}/cargo";
          DOTNET_CLI_HOME = "${dataHome}/dotnet";
          GOPATH = "${dataHome}/go";
          GRADLE_USER_HOME = "${dataHome}/gradle";
          GTK2_RC_FILES = "${configHome}/gtk-2.0/gtkrc";
          HISTFILE = "${stateHome}/bash/history";
          LESSHISTFILE = "${cacheHome}/less/history";
          NODE_REPL_HISTORY = "${stateHome}/node_repl_history";
          NPM_CONFIG_CACHE = "${cacheHome}/npm";
          NPM_CONFIG_INIT_MODULE = "${configHome}/npm/config/npm-init.js";
          NPM_CONFIG_PREFIX = "${stateHome}/npm";
          NPM_CONFIG_TMP = "${stateHome}/npm";
          NUGET_PACKAGES = "${cacheHome}/NuGetPackages";
          OMNISHARPHOME = "${configHome}/omnisharp";
          RUSTUP_HOME = "${dataHome}/rustup";
          STACK_ROOT = "${dataHome}/stack";
          TERMINFO = "${dataHome}/terminfo";
          TERMINFO_DIRS = "${dataHome}/terminfo\${TERMINFO_DIRS:+:$TERMINFO_DIRS}";
          VAGRANT_HOME = "${dataHome}/vagrant";
          WINEPREFIX = "${dataHome}/wine";
          XCOMPOSECACHE = "${cacheHome}/X11/xcompose";
          _Z_DATA = "${dataHome}/z";
          # keep-sorted end
        };
      };

      xresources.path = "${config.xdg.configHome}/.Xresources";

      xdg.portal.xdgOpenUsePortal = true;
    };

}
