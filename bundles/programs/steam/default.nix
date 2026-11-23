{
  nixos = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraProfile = ''
          export DXVK_HUD=compiler
          export PROTON_ENABLE_WAYLAND=1
          export PROTON_FSR4_UPGRADE=1
          export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
          unset TZ

          # extest unwraps its compositor connection and panics when none is
          # available; the panic crosses its extern "C" boundary and aborts
          # Steam. Gamescope runs Steam as an X11 client with no
          # WAYLAND_DISPLAY (it only exports one under --expose-wayland) and
          # provides XTEST natively via libei, so the shim is both unusable and
          # unnecessary there. Require gamescope's own markers as well, so any
          # other compositor-less launch keeps the previous extest behaviour.
          if [ -z "''${WAYLAND_DISPLAY:-}" ] &&
            { [ "''${XDG_CURRENT_DESKTOP:-}" = gamescope ] || [ -n "''${GAMESCOPE_WAYLAND_DISPLAY:-}" ]; }; then
            unset LD_PRELOAD
          fi
        '';
      };
      extraCompatPackages = with pkgs; [
        proton-cachyos_x86_64_v3 # from chaotic
        steam-play-none # Allows you to run a game without Proton if it is otherwise forced.
      ];
      extest.enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
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
}
