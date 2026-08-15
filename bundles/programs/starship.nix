{
  bundleLib,
  lib,
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "starship"] {
  home-manager = {
    programs.starship = {
      enable = true;
      settings = let
        using = symbol: style: {
          inherit symbol;
          format = "[$symbol ](${style})";
        };
        via = symbol: style: {
          inherit symbol;
          format = "via [$symbol ](${style})";
        };
      in {
        add_newline = true;
        format = lib.concatStrings [
          "[ ](238)$os"
          "$all[ ->](237)$character"
        ];

        character = {
          success_symbol = "";
          error_symbol = "";
        };

        username = {
          style_user = "white";
          style_root = "black";
          format = "[$user]($style) ";
          show_always = true;
        };

        hostname = {
          format = "at [$hostname]($style) ";
          style = "bold dimmed blue";
        };

        directory = rec {
          truncation_length = 3;
          truncation_symbol = "…/";
          home_symbol = "󰋞 ";
          read_only_style = "197";
          read_only = "  ";
          format = "in [$path]($style)[$read_only]($read_only_style) ";

          substitutions = lib.mapAttrs' (n: v: lib.nameValuePair "${home_symbol}/${n}" v) {
            # # keep-sorted start
            ".config" = " ";
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Games" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "Projects" = "󱌢 ";
            "Projects/gaia" = "󰳊 ";
            "Videos" = " ";
            # # keep-sorted end
          };
        };

        container = using "󰏖 " "yellow dimmed";
        python = using " " "yellow";
        nodejs = using " " "yellow";
        lua = using "󰢱 " "blue";
        rust = using " " "red";
        java = using " " "red";
        c = using " " "blue";
        golang = using " " "blue";
        docker_context = using " " "blue";
        nix_shell = via " " "blue";

        git_branch = {
          symbol = "󰊢 ";
          format = "on [$symbol$branch]($style) ";
          truncation_length = 6;
          truncation_symbol = "…/";
          style = "bold green";
        };
        git_status = {
          format = "[\\($all_status$ahead_behind\\)]($style) ";
          style = "bold green";
          conflicted = "🏳";
          up_to_date = " ";
          untracked = " ";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          stashed = "󰏗 ";
          modified = " ";
          staged = "[++\\($count\\)](green)";
          renamed = "󰖷 ";
          deleted = " ";
        };
      };
    };
  };
}
