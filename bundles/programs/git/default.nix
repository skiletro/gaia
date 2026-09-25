{lib, ...}: {
  home-manager = {pkgs, ...}: {
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

      lazygit = {
        enable = true;
        settings = {
          gui = {
            nerdFontsVersion = "3";
            spinner.frames = [
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
          git.diffRenderers = [
            {
              command = "${lib.getExe pkgs.delta} --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
              colorArg = "always";
            }
          ];
          disableStartupPopups = true;
          promptToReturnFromSubprocess = false;
        };
      };

      gh.enable = true;

      gh-dash.enable = true;
    };

    home.shellAliases.lg = "lazygit";
  };
}
