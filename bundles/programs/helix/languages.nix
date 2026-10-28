{lib, ...}: {
  requires = ["wakatime"];

  home-manager = {pkgs, ...}: {
    programs.helix = {
      extraPackages = with pkgs; [
        # keep-sorted start
        bash-language-server # Bash
        clippy # Rust
        deadnix # Nix
        docker-compose-language-service # Docker Compose
        dockerfile-language-server # Dockerfile
        gopls # Go
        marksman # Markdown
        nil # Nix
        nixd # Nix
        nufmt # Nu
        prettier # HTML/CSS/JS
        qt6.qtdeclarative # QML
        rust-analyzer # Rust
        rustfmt # Rust
        taplo # TOML
        typescript-language-server # TS
        vscode-langservers-extracted # TS/JS/HTML
        yaml-language-server # YAML
        # keep-sorted end
      ];
      languages = {
        language-server = {
          # keep-sorted start block=yes
          emmet-lsp = {
            command = lib.getExe pkgs.emmet-language-server;
            args = ["--stdio"];
          };
          gopls.config.gofumpt = true;
          harper = {
            command = lib.getExe pkgs.harper;
            args = ["--stdio"];
            config.harper-ls.dialect = "British";
          };
          wakatime = {
            command = "wakatime-ls";
          };
          # keep-sorted end
        };
        language =
          map
          (
            elem:
              elem
              // {
                language-servers = (elem.language-servers or []) ++ ["wakatime"];
              }
          )
          [
            # keep-sorted start block=yes by_regex=['name = "(.*)"']
            {
              name = "c";
              formatter.command = lib.getExe' pkgs.clang-tools "clang-format";
              language-servers = ["clangd"];
            }
            {
              name = "fish";
              formatter.command = "fish_indent";
              language-servers = ["fish-lsp"];
              auto-format = true;
            }
            {
              name = "go";
              language-servers = ["gopls"];
              auto-format = true;
            }
            {
              name = "html";
              formatter = {
                command = "prettier";
                args = [
                  "--parser"
                  "html"
                ];
              };
              language-servers = [
                "vscode-html-language-server"
                "emmet-lsp"
              ];
            }
            {
              name = "nix";
              formatter.command = lib.getExe pkgs.alejandra;
              auto-format = true;
              language-servers = [
                "nixd"
                "nil"
              ];
            }
            {
              name = "tsx";
              formatter = {
                command = "prettier";
                args = [
                  "--parser"
                  "typescript"
                ];
              };
              language-servers = [
                "vscode-html-language-server"
                "emmet-lsp"
              ];
            }
            {
              name = "css";
              language-servers = ["vscode-css-language-server"];
            }
            {
              name = "scss";
              language-servers = ["vscode-css-language-server"];
            }
            {
              name = "nu";
              language-servers = ["nu"];
            }
            {
              name = "javascript";
              language-servers = ["typescript-language-server"];
            }
            {
              name = "typescript";
              language-servers = ["typescript-language-server"];
            }
            {
              name = "rust";
              language-servers = ["rust-analyzer"];
            }
            {
              name = "markdown";
              language-servers = [
                "marksman"
                "harper"
              ];
            }
            {
              name = "qml";
              language-servers = [
                "qmlls"
              ];
            }
            # keep-sorted end
          ];
      };
    };
  };
}
