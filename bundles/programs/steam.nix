{
  bundleLib,
  self',
  inputs,
  inputs',
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "steam" ] {

  gaia.autoStart = [ "steam -silent -console" ];

  home-manager =
    { osConfig, pkgs, ... }:
    {
      imports = [ inputs.steam-config-nix.homeModules.default ];

      programs.steam.config = rec {
        enable = lib.mkIf osConfig.programs.steam.enable true;
        closeSteam = true;
        defaultCompatTool = "Proton-CachyOS x86-64-v3";
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
                  MANGOHUD_CONFIG = "fps_limit=${fpsCap},no_display";
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
              compatTool = "proton_11";
              launchOptions = {
                env = {
                  PROTON_FSR4_UPGRADE = 1;
                  MANGOHUD_CONFIG = "fps_limit=90,no_display";
                  PROTON_ENABLE_HDR = 1;
                  DXVK_HDR = 1;
                  PROTON_NO_ESYNC = 1;
                  PROTON_NO_FSYNC = 1;
                  PROTON_USE_NTSYNC = 1;
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

  nixos =
    { pkgs, ... }:
    {

      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraProfile = ''
            export DXVK_HUD=compiler
            export PROTON_ENABLE_WAYLAND=1
            export PROTON_ENABLE_HDR=1
            export PROTON_FSR4_UPGRADE=1
            export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
            unset TZ
          '';
        };
        extraCompatPackages = [
          self'.packages.proton-cachyos_x86_64_v3
          inputs'.nixpkgs-xr.packages.proton-ge-rtsp-bin
          pkgs.steam-play-none # Allows you to run a game without Proton if it is otherwise forced.
        ];
        extest.enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      programs.gamescope.enable = true;

      environment.systemPackages = with pkgs; [
        # keep-sorted start
        sgdboop
        steamtinkerlaunch
        # keep-sorted end
      ];

      boot.kernel.sysctl."vm.max_map_count" = 2147483642;
    };

  darwin = {
    config.homebrew.casks = [ "steam" ];

    options.programs.steam.enable = lib.mkOption { default = false; };
  };
}
