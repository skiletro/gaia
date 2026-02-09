{
  lib,
  config,
  self,
  ...
}:
{
  options.erebus.services.rnnoise.enable = lib.mkEnableOption "RNNoise Microphone Noise Cancelling";

  imports = [ self.nixosModules.rnnoise ];

  config = lib.mkIf config.erebus.services.rnnoise.enable {
    services.rnnoise = {
      enable = true;
      nodeName = "alsa_card.usb-BLUE_MICROPHONE_Blue_Snowball_201305-00";
      nodePrettyName = "Blue Snowball";
    };
  };
}
