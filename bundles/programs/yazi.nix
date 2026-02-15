{
  home-manager =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        plugins = {
          inherit (pkgs.yaziPlugins) full-border git;
        };
        initLua =
          # lua
          ''
            require("full-border"):setup()
            require("git"):setup()
          '';
      };
    };
}
