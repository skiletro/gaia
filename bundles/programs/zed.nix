{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "zed" ] {

  home-manager =
    { pkgs, config, ... }:
    {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "nix"
        ];
        userSettings = {
          # keep-sorted start block=yes
          auto_update = false;
          base_keymap = "JetBrains";
          collaboration_panel.button = false;
          colorize_brackets = true;
          cursor_blink = false;
          disable_ai = true;
          features.edit_prediction_provider = "none";
          git_panel.button = false;
          helix_mode = true;
          load_direnv = "shell_hook";
          notification_panel.dock = "right";
          project_panel = {
            git_status = true;
            dock = "right";
          };
          relative_line_numbers = true;
          restore_on_startup = "none";
          search.regex = false;
          tab_bar = {
            show = true;
            show_nav_history_buttons = false;
          };
          tabs.file_icons = true;
          telemetry = {
            metrics = false;
            diagnostics = false;
          };
          title_bar.show_sign_in = false;
          ui_font_size = lib.mkForce (config.stylix.fonts.sizes.terminal * 4.0 / 3.0);
          # keep-sorted end
        };
        extraPackages = with pkgs; [
          nixd
          nil
        ];
      };
    };

}
