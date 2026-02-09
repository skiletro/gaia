{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.erebus.services.sunshine.enable = lib.mkEnableOption "Sunshine Game Streaming";

  config = lib.mkIf config.erebus.services.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true; # Wayland
      openFirewall = true;
      applications.apps =
        lib.lists.forEach
          [
            {
              name = "Desktop";
              auto-detach = "true";
            }
            {
              name = "Steam Big Picture";
              detached = [
                "${lib.getExe' pkgs.xdg-utils "xdg-open"} steam://open/bigpicture"
              ];
            }
            {
              name = "Pegasus";
              cmd = "exec ${lib.getExe pkgs.pegasus-frontend}";
            }
          ]
          (
            attr:
            attr
            // {
              exclude-global-prep-cmd = "false";
              prep-cmd =
                let
                  kscreen = lib.getExe pkgs.kdePackages.libkscreen;
                  gnome-randr = lib.getExe pkgs.gnome-randr;

                  monitor = "DP-3";

                  defaultMode = "3440x1440@165";
                  sunshineMode = "\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}\${SUNSHINE_CLIENT_FPS}";
                in
                if config.erebus.desktop.gnome.enable then
                  {
                    do = ''sh -c "${gnome-randr} modify -m ${sunshineMode} ${monitor}"'';
                    undo = "${gnome-randr} modify -m ${defaultMode}.001+vrr ${monitor}";
                  }
                else if config.erebus.desktop.hyprland.enable then
                  {
                    do = ''sh -c "hyprctl keyword monitor ${monitor},${sunshineMode},auto,auto"'';
                    undo = ''sh -c "hyprctl keyword monitor ${monitor},${defaultMode},auto,auto"'';
                  }
                else
                  {
                    do = ''sh -c "${kscreen}" output.${monitor}.mode.${sunshineMode}'';
                    undo = "${kscreen} output.${monitor}.mode.${defaultMode}";
                  };
            }
          );
    };
  };
}
