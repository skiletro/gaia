{
  bundleLib,
  lib,
  inputs,
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "pwa"] {
  home-manager = {osConfig, ...}: {
    imports = [inputs.chromium-webapps.homeManagerModules.default];

    programs.chromium-webapps = {
      enable = true;
      package =
        lib.mkIf osConfig.programs.helium.enable osConfig.programs.helium.package;
      webApps = [
        {
          name = "Instagram";
          url = "https://instagram.com/direct/inbox/";
          icon = "instagram";
        }
        {
          name = "Proton Mail";
          url = "https://mail.proton.me/u/0/";
          icon = "proton-mail";
        }
        {
          name = "WhatsApp";
          url = "https://web.whatsapp.com/";
          icon = "whatsapp";
        }
      ];
    };
  };
}
