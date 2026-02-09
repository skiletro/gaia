{
  config,
  lib,
  ...
}:
{
  options.erebus.programs.nu.enable = lib.mkEnableOption "Nushell configuration";

  config = lib.mkIf config.erebus.programs.nu.enable {
    programs.nushell = {
      enable = true;
      extraConfig =
        # nu
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
      environmentVariables = {

      }
      // (builtins.mapAttrs (_name: toString) config.home.sessionVariables);
    };

    home.shell.enableNushellIntegration = true;
  };
}
