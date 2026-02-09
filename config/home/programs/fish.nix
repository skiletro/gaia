{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.programs.fish.enable = lib.mkEnableOption "Fish shell configuration";

  config = lib.mkIf config.erebus.programs.fish.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit =
        # fish
        ''
          set fish_greeting # disable prompt

          ulimit -n 10240 # increase file descriptor limit

          ${lib.getExe pkgs.nix-your-shell} fish | source
        '';
    };

    home.shell.enableFishIntegration = true;
  };
}
