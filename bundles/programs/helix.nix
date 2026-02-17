{
  bundleLib,
  inputs',
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "helix" ] {

  gaia.programs.wakatime.enable = true;

  home-manager =
    { pkgs, ... }:
    {
      programs.helix = {
        enable = true;
        package = inputs'.helix.packages.helix.overrideAttrs (_: {
          patches = [
            # Keep LSP completions active when typing server-trigger characters
            (pkgs.fetchurl {
              url = "https://patch-diff.githubusercontent.com/raw/helix-editor/helix/pull/14556.patch";
              sha256 = "sha256-YLohyMbQMKcOu16BhyJ0jwTfjX0JkPuX5z7xgwI+AMc=";
            })
          ];
        });
        extraPackages = with pkgs; [
          # keep-sorted start
          bash-language-server # Bash
          clippy # Rust
          deadnix # Nix
          docker-compose-language-service # Docker Compose
          dockerfile-language-server # Dockerfile
          gopls # Go
          marksman # Markdown
          mono # C#
          msbuild # C# Unity
          netcoredbg # C#
          nil # Nix
          nixd # Nix
          nufmt # Nu
          prettier # HTML/CSS/JS
          rust-analyzer # Rust
          rustfmt # Rust
          taplo # TOML
          typescript-language-server # TS
          vscode-langservers-extracted # TS/JS/HTML
          yaml-language-server # YAML
          # keep-sorted end
        ];
        defaultEditor = true;
        languages = {
          language-server = {
            # keep-sorted start block=yes
            emmet-lsp = {
              command = lib.getExe pkgs.emmet-language-server;
              args = [ "--stdio" ];
            };
            gopls.config.gofumpt = true;
            harper = {
              command = lib.getExe pkgs.harper;
              args = [ "--stdio" ];
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
                  language-servers = (elem.language-servers or [ ]) ++ [ "wakatime" ];
                }
              )
              [
                # keep-sorted start block=yes by_regex=['name = "(.*)"']
                {
                  name = "c";
                  formatter.command = lib.getExe' pkgs.clang-tools "clang-format";
                  language-servers = [ "clangd" ];
                }
                {
                  name = "fish";
                  formatter.command = "fish_indent";
                  language-servers = [ "fish-lsp" ];
                  auto-format = true;
                }
                {
                  name = "go";
                  language-servers = [ "gopls" ];
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
                  formatter = {
                    command = lib.getExe pkgs.nixfmt;
                    auto-format = true;
                  };
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
                  language-servers = [ "vscode-css-language-server" ];
                }
                {
                  name = "scss";
                  language-servers = [ "vscode-css-language-server" ];
                }
                {
                  name = "nu";
                  language-servers = [ "nu" ];
                }
                {
                  name = "javascript";
                  language-servers = [ "typescript-language-server" ];
                }
                {
                  name = "typescript";
                  language-servers = [ "typescript-language-server" ];
                }
                {
                  name = "rust";
                  language-servers = [ "rust-analyzer" ];

                }
                {
                  name = "markdown";
                  language-servers = [
                    "marksman"
                    "harper"
                  ];
                }
                # keep-sorted end
              ];
        };
        settings = {
          editor = {
            bufferline = "multiple";
            cursorline = true;
            true-color = true;
            color-modes = true;
            line-number = "relative";
            rainbow-brackets = true;
            rulers = [ 120 ];
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
              center = [ "file-name" ];
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
          keys.normal."=" = ":format";
        };
      };
    };

}
