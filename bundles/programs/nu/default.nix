{lib, ...}: {
  requires = ["starship"];

  home-manager = {
    config,
    lib,
    pkgs,
    ...
  }: {
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
      # Home Manager values can contain POSIX shell expansions. Evaluate its
      # session script before importing them, rather than loading literal strings.
      extraEnv =
        # nu
        ''
          load-env (
            ^${lib.getExe pkgs.bash} -c ${lib.hm.nushell.toNushell {} ''
            . ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
            ${lib.getExe' pkgs.coreutils "env"} -0
          ''}
            | split row (char nul)
            | parse --regex '(?s)^(?<name>[^=]+)=(?<value>.*)$'
            | where name in ${lib.hm.nushell.toNushell {} (builtins.attrNames config.home.sessionVariables ++ ["__HM_SESS_VARS_SOURCED"])}
            | transpose --header-row --as-record
          )
        '';
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

    home.shellAliases = {
      vf = "ssh -p 2200 git.warm.vodka";
      n = "nix";
    };
  };

  nixos = {pkgs, ...}: {
    programs.bash.interactiveShellInit =
      # bash
      ''
        if [ "$TERM" != "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ] && [ "$SHLVL" -le "1" ]; then
          exec ${lib.getExe pkgs.nushell}
        fi
      '';
  };
}
