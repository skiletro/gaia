{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "gamemode" ] {

  nixos =
    { pkgs, config, ... }:
    {
      programs.gamemode = {
        enable = true;
        enableRenice = false;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
          };
          custom =
            let
              powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
              hyprctl =
                if config.programs.hyprland.enable then
                  (lib.getExe' config.programs.hyprland.package "hyprctl")
                else
                  "true"; # do nothing essentially
            in
            {
              start =
                (pkgs.writeShellScript "gamemode-start"
                  # sh
                  ''
                    ${powerprofilesctl} set performance
                    ${hyprctl} --batch "\
                      keyword animations:enabled 0;\
                      keyword animation borderangle,0; \
                      keyword decoration:shadow:enabled 0;\
                      keyword decoration:blur:enabled 0;\
                      keyword decoration:fullscreen_opacity 1;\
                      keyword general:gaps_in 0;\
                      keyword general:gaps_out 0;\
                      keyword general:border_size 1;\
                      keyword decoration:rounding 0"
                    ${hyprctl} notify 1 5000 "rgb(000000)" "Gamemode ON"
                  ''
                ).outPath;
              end =
                (pkgs.writeShellScript "gamemode-end"
                  # sh
                  ''
                    ${hyprctl} reload
                    ${powerprofilesctl} set power-saver
                    ${hyprctl} notify 1 5000 "rgb(000000)" "Gamemode OFF"
                  ''
                ).outPath;
            };
        };
      };
    };

}
