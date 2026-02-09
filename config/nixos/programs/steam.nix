{
  config,
  lib,
  pkgs,
  pkgs',
  inputs',
  self,
  ...
}:
{
  imports = [ self.nixosModules.steam ];

  options.erebus.programs.steam.enable = lib.mkEnableOption "Steam and Steam tools";

  config = lib.mkIf config.erebus.programs.steam.enable {
    programs.steam = rec {
      enable = true;
      extraCompatPackages = with pkgs; [
        pkgs'.proton-cachyos_x86_64_v3
        pkgs'.proton-cachyos_x86_64_v4
        inputs'.nixpkgs-xr.packages.proton-ge-rtsp-bin
        steam-play-none # Allows you to run a game without Proton if it is otherwise forced.
      ];
      defaultCompatTool = "Proton-CachyOS x86-64-v4";
      extest.enable = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      apps = {
        counter-strike-2 = {
          id = 730;
          launchOptions = {
            env = {
              PULSE_LATENCY_MSEC = 60;
              SDL_AUDIO_DRIVER = "pulse";
              TZ = null;
              MANGOHUD_CONFIG = "fps_limit=164,no_display";
            };
            wrappers = [
              (lib.getExe' pkgs.mangohud "mangohud")
              "gamemoderun"
            ];
            args = [
              "+exec autoexec"
            ];
          };
        };
        cyberpunk-2077 = {
          id = 1091500;
          compatTool = defaultCompatTool;
          launchOptions = {
            env = {
              PROTON_FSR4_UPGRADE = 1;
              MANGOHUD_CONFIG = "fps_limit=164,fps_only";
            };
            wrappers = [
              (lib.getExe' pkgs.mangohud "mangohud")
              "gamemoderun"
            ];
            args = [
              "-skipStartScreen"
              "--intro-skip"
              "--launcher-skip"
            ];
          };
        };
        monster-hunter-wilds = {
          id = 2246340;
          compatTool = defaultCompatTool;
          launchOptions = {
            env = {
              LD_PRELOAD = "";
              ENABLE_VKBASALT = 1;
              WINEDLLOVERRIDES = "dinput8=n,b"; # REFramework
            };
            wrappers = [ "gamemoderun" ];
          };
        };
      };
    };

    home-manager.sharedModules = lib.singleton (hm: {
      xdg.autostart.entries = hm.config.lib.erebus.autostartEntry "Steam Silent" "${lib.getExe config.programs.steam.package} -silent -console";
    });
  };
}
