{
  bundleLib,
  self',
  inputs',
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "steam" ] {

  gaia.autoStart = [ "steam -silent -console" ];

  nixos =
    { pkgs, ... }:
    {

      programs.steam = rec {
        enable = true;
        extraCompatPackages = [
          self'.packages.proton-cachyos_x86_64_v3
          inputs'.nixpkgs-xr.packages.proton-ge-rtsp-bin
          pkgs.steam-play-none # Allows you to run a game without Proton if it is otherwise forced.
        ];
        defaultCompatTool = "Proton-CachyOS x86-64-v3";
        extest.enable = true;
        protontricks.enable = true;
        gamescopeSession.enable = true;
        apps =
          let
            fpsCap = toString 174;

            gamemode = "gamemoderun";
            mangohud = lib.getExe' pkgs.mangohud "mangohud";
          in
          {
            # keep-sorted start block=yes
            counter-strike-2 = {
              id = 730;
              launchOptions = {
                env = {
                  PULSE_LATENCY_MSEC = 60;
                  SDL_AUDIO_DRIVER = "pulse";
                  TZ = null;
                  MANGOHUD_CONFIG = "fps_limit=${fpsCap},no_display";
                };
                wrappers = [
                  mangohud
                  gamemode
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
                  MANGOHUD_CONFIG = "fps_limit=${fpsCap},fps_only";
                  WINEDLLOVERRIDES = "winmm=n, b";
                  PROTON_ENABLE_HDR = 1;
                  DXVK_HDR = 1;
                };
                wrappers = [
                  mangohud
                  gamemode
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
                  PROTON_ENABLE_HDR = 1;
                  DXVK_HDR = 1;
                };
                wrappers = [ gamemode ];
              };
            };
            red-dead-redemption-ii = {
              id = 1174180;
              compatTool = defaultCompatTool;
              launchOptions = {
                env = {
                  PROTON_FSR4_UPGRADE = 1;
                  MANGOHUD_CONFIG = "fps_limit=90,fps_only";
                  PROTON_ENABLE_HDR = 1;
                  DXVK_HDR = 1;
                };
                wrappers = [
                  mangohud
                  gamemode
                ];
              };
            };
            vrchat = {
              id = 438100;
              compatTool = "GE-Proton-rtsp";
              launchOptions = {
                env."PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES" = 1;
                wrappers = [ gamemode ];
              };
            };
            # keep-sorted end
          };
      };
    };

  darwin.homebrew.casks = [ "steam" ];

}
