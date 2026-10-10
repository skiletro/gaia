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
        sleep 2.5
        ${wlopm} --off eDP-1
        sleep 1.25
        ${wlopm} --on eDP-1
      ) &
    '';
  };
}
