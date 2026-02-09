{
  self,
  lib,
  config,
  ...
}:
{
  imports = [ self.homeModules.pwa ];

  options.erebus.programs.pwa.enable = lib.mkEnableOption "Progressive Web Apps";

  config = lib.mkIf config.erebus.programs.pwa.enable {
    programs.firefoxpwa = {
      enable = true;
      webapps = {
        "WhatsApp" = {
          url = "https://web.whatsapp.com";
          manifestUrl = "https://web.whatsapp.com/data/manifest.json";
          categories = [ "Network" ];
          icon = "whatsapp";
        };
        "Instagram" = {
          url = "https://instagram.com";
          manifestUrl = "https://instagram.com/data/manifest.json";
          categories = [ "Network" ];
          icon = "instagram";
        };
      };
    };
  };
}
