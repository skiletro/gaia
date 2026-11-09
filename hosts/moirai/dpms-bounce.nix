{
  home-manager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.wlopm];

    wayland.windowManager.mango.autostart_sh = let
      wlopm = lib.getExe pkgs.wlopm;
    in ''
      (
        sleep 1.5
        ${wlopm} --off eDP-1
        sleep 0.5
        ${wlopm} --on eDP-1
      ) &
    '';
  };
}
