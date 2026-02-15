{ bundleLib, ... }:
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
              show-banner: false
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

}
