{
  home-manager =
    { pkgs, ... }:
    {
      programs = {
        git = {
          enable = true;
          ignores = [
            ".DS_Store"
            "**/.DS_Store"
            ".direnv/"
          ];
          settings = {
            user = {
              name = "jamie";
              email = "${"git"}${"@"}${"skilet.ro"}";
            };
            pull.rebase = true;
            push.autoSetupRemote = true;
          };
        };

        diff-so-fancy = {
          enable = true;
          enableGitIntegration = true;
        };

        lazygit = {
          enable = true;
          settings = {
            gui = {
              nerdFontsVersion = "3";
              spinner.frames = [
                "⠟"
                "⠯"
                "⠷"
                "⠾"
                "⠽"
                "⠻"
              ];
            };
            git.pagers = [
              {
                pager = "diff-so-fancy";
              }
            ];
            disableStartupPopups = true;
          };
        };
      };

      home = {
        shellAliases.lg = "lazygit";
        packages = [ pkgs.gh ]; # necessary evil
      };
    };
}
