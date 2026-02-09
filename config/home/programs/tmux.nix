{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.programs.tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";

  config = lib.mkIf config.erebus.programs.tmux.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      plugins = with pkgs.tmuxPlugins; [
        catppuccin
        sensible
        yank
      ];
    };
  };
}
