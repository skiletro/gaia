{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.rnnoise;
in
{
  options.services.rnnoise = {
    enable = lib.mkEnableOption "RNNoise Microphone Noise Cancelling";
    nodeName = lib.mkOption {
      type = lib.types.str;
      default = null;
    };
    nodePrettyName = lib.mkOption {
      type = lib.types.str;
      default = cfg.nodeName;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.singleton {
      xdg.configFile."pipewire/pipewire.conf.d/99-input-denoising.conf".text = builtins.toJSON {
        "context.modules" = [
          {
            "name" = "libpipewire-module-filter-chain";
            "args" = {
              "node.description" = "${cfg.nodePrettyName} (RNNoise)";
              "media.name" = "Noise Canceling source";
              "filter.graph" = {
                "nodes" = [
                  {
                    "type" = "ladspa";
                    "name" = "rnnoise";
                    "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                    "label" = "noise_suppressor_stereo";
                    "control" = {
                      "VAD Threshold (%)" = 85.0;
                      "VAD Grace Period (ms)" = 350;
                      "Retroactive VAD Grace (ms)" = 80;
                    };
                  }
                ];
              };
              "audio.position" = [
                "FL"
                "FR"
              ];
              "capture.props" = {
                "node.name" = "effect_input.rnnoise";
                "target.node" = cfg.nodeName;
                "node.passive" = true;
              };
              "playback.props" = {
                "node.name" = "effect_output.rnnoise";
                "media.class" = "Audio/Source";
              };
            };
          }
        ];
      };
    };
  };
}
