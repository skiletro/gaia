{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "zed" ] {

  home-manager =
    { pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "nix"
        ];
        userSettings = {
          helix_mode = true;
          title_bar.show_sign_in = false;
          features.edit_prediction_provider = "none";
          telemetry = {
            metrics = false;
            diagnostics = false;
          };
        };
        extraPackages = with pkgs; [
          nixd
          nil
        ];
      };
    };

}
