{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.profiles.gaming.enable =
    lib.mkEnableOption "gaming related *stuff*. This includes VR.";

  config = lib.mkIf config.erebus.profiles.gaming.enable {
    erebus = {
      programs = {
        gamemode.enable = true;
        gsr.enable = true;
        steam.enable = true;
        wivrn.enable = true;
      };

      services = {
        sunshine.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      bazaar
      lsfg-vk
      lsfg-vk-ui # frame gen
      ludusavi
      # keep-sorted end
    ];

    hardware = {
      xone.enable = true;
      xpadneo.enable = true;
      xpad-noone.enable = true;
    };

    # for games, I am going to install them imperatively from now on, hence the bazaar install
    services.flatpak.enable = true;

    home-manager.sharedModules = lib.singleton {
      erebus.programs.prismlauncher.enable = true;
      programs.mangohud.enable = true;
    };
  };
}
