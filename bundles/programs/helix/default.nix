{inputs', ...}: {
  home-manager = {
    programs.helix = {
      enable = true;
      package = inputs'.helix.packages.helix;
      defaultEditor = true;
      settings = {
        editor = {
          mouse = false;
          bufferline = "multiple";
          cursorline = true;
          true-color = true;
          color-modes = true;
          line-number = "relative";
          rainbow-brackets = true;
          rulers = [
            80
            120
          ];
          jump-label-alphabet = "ghfjdksltyrubnvm";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            skip-levels = 1;
          };
          auto-pairs = true;
          lsp = {
            auto-signature-help = false;
            display-messages = true;
            display-progress-messages = true;
            display-inlay-hints = true;
          };
          end-of-line-diagnostics = "hint";
          inline-diagnostics = {
            cursor-line = "error";
            other-lines = "disable";
          };
          statusline = {
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
            separator = " ";
            left = [
              "mode"
              "separator"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = ["file-name"];
            right = [
              "spinner"
              "version-control"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
          };
        };
        keys = {
          normal = {
            "up" = "no_op";
            "down" = "no_op";
            "left" = "no_op";
            "right" = "no_op";
            "=" = ":format";
          };
          insert = {
            "up" = "no_op";
            "down" = "no_op";
            "left" = "no_op";
            "right" = "no_op";
          };
        };
      };
    };
  };
}
