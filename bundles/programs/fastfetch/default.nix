{
  home-manager = {
    programs.fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        logo = {
          type = "kitty";
          source = "/run/current-system/sw/share/icons/hicolor/1024x1024/apps/nix-snowflake.png";
          padding = {
            top = 0;
            left = 1;
            right = 0;
          };
          printRemaining = true;
          width = 36;
        };
        display = {
          separator = "  ";
          brightColor = false;
          disableLinewrap = true;
        };
        modules = [
          "break"
          "break"
          {
            type = "os";
            key = "Distro:       ";
            keyColor = "blue";
            format = "{name} {version-id}";
          }
          "break"
          {
            type = "kernel";
            key = "  Kernel:     ";
            keyColor = "cyan";
            format = "{release}";
          }
          {
            type = "wm";
            key = "   Compositor:";
            keyColor = "cyan";
            format = "{pretty-name}";
          }
          {
            type = "terminal";
            key = "    Terminal: ";
            keyColor = "blue";
            format = "{pretty-name}";
          }
          {
            type = "cpu";
            key = "     CPU:     ";
            keyColor = "blue";
            format = "{name}";
          }
          {
            type = "gpu";
            key = "    GPU:      ";
            keyColor = "cyan";
            format = "{name}";
          }
          {
            type = "display";
            key = "   Display:   ";
            keyColor = "cyan";
            format = "{width}x{height} @ {refresh-rate} Hz";
          }
          {
            type = "memory";
            key = "  Memory:     ";
            keyColor = "blue";
            format = "{total}";
          }
          {
            type = "disk";
            key = " OS Age:      ";
            keyColor = "blue";
            folders = "/";
            format = "{days} days";
          }
        ];
      };
    };
  };
}
