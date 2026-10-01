{lib, ...}: {
  requires = ["desktops.mango"];

  nixos = {
    config,
    pkgs,
    ...
  }: {
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
        ]
        (
          attr:
            attr
            // {
              exclude-global-prep-cmd = "false";
              prep-cmd = let
                monitor = "DP-3";
                sunshineMode = "\${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}Hz";
              in [
                {
                  do = ''sh -c '${lib.getExe pkgs.wlr-randr} --output ${monitor} --custom-mode "${sunshineMode}"' '';
                  undo = "${lib.getExe' config.programs.mango.package "mmsg"} dispatch reload_config";
                }
              ];
            }
        );
    };
  };
}
