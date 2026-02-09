{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.programs.yazi.enable = lib.mkEnableOption "yazi, the terminal file browser";

  config = lib.mkIf config.erebus.programs.yazi.enable {
    programs.yazi = {
      enable = true;
      plugins = { inherit (pkgs.yaziPlugins) full-border git; };
      initLua =
        # lua
        ''
          require("full-border"):setup()
          require("git"):setup()
        '';
    };
  };
}
