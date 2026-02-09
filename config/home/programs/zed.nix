{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.programs.zed.enable = lib.mkEnableOption "Zed Editor";

  config = lib.mkIf config.erebus.programs.zed.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
      ];
      userSettings = {
        helix_mode = true;

        ui_font_size = lib.mkForce 14;
        buffer_font_size = lib.mkForce 13;

        features.edit_prediction_provider = "none";
        telemetry = {
          metrics = false;
          diagnostics = false;
        };
      };
      extraPackages = with pkgs; [ omnisharp-roslyn ];
    };
  };
}
