{
  bundleLib,
  self',
  inputs',
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "steam" ] {

  gaia.autoStart = [ "steam -silent -console" ];

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
  };
}
