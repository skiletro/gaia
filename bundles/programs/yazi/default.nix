{
  home-manager = {pkgs, ...}: {
    programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
      shellWrapperName = "yy";
      extraPackages = [pkgs.glow];
      plugins.piper = pkgs.yaziPlugins.piper;
      settings.plugin.prepend_previewers = [
        {
          url = "*.md";
          run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
        }
      ];
    };
  };
}
