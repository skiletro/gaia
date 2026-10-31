{
  home-manager = {
    programs.noctalia.settings = {
      # Plugins
      plugins = {
        enabled = [];
        source = [
          {
            name = "community";
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            enabled = true;
          }
        ];
      };

      plugin_settings = {};
    };
  };
}
