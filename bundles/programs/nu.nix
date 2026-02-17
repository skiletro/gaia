{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "nu" ] {

  home-manager =
    { config, ... }:
    {
      programs.nushell = {
        enable = true;
        extraConfig =
          #nu
          ''
            $env.config = {
              show_banner: false
              completions: {
                external: {
                  enable: true
                }
              }
              highlight_resolved_externals: true
            };            
          '';
        loginFile.text =
          # nu
          ''
            ulimit -n 10240 # increase file descriptor limit
          '';
        environmentVariables = { } // (builtins.mapAttrs (_: toString) config.home.sessionVariables);
      };

      home.shell.enableNushellIntegration = true;

      programs.nix-your-shell = {
        enable = true;
        enableNushellIntegration = true;
      };

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };

  nixos =
    { pkgs, ... }:
    {
      programs.bash.interactiveShellInit =
        # bash
        ''
          if [ "$TERM" != "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ] && [ "$SHLVL" == "1" ]; then
            exec ${lib.getExe pkgs.nushell}
          fi
        '';
    };

  darwin =
    { pkgs, ... }:
    {
      programs.zsh.interactiveShellInit =
        # zsh
        ''
          if [ "$TERM" != "dumb" ] && [ -z "$ZSH_EXECUTION_STRING" ] && [ "$SHLVL" == "1" ]; then
            exec ${lib.getExe pkgs.nushell} --config ~/.config/nushell/config.nu
          fi
        '';
    };

}
