{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "gamemode" ] {

  nixos =
    { pkgs, ... }:
    {
      power-profiles-daemon.enable = true;

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
              powerprofile = profile: "${lib.getExe pkgs.power-profiles-daemon} set ${profile}";
              notif =
                title: content:
                "${lib.getExe' pkgs.libnotify "notify-send"} notify-send -u low -a 'Gamemode' '${title}' '${content}'";
            in
            {
              start =
                (pkgs.writeShellScript "gamemode-start"
                  # sh
                  ''
                    ${powerprofile "performance"}
                    ${notif "Gamemode enabled" "Switching to performance mode."}
                  ''
                ).outPath;
              end =
                (pkgs.writeShellScript "gamemode-end"
                  # sh
                  ''
                    ${powerprofile "power-saver"}
                    ${notif "Gamemode disabled" "Switching to power saving mode."}
                  ''
                ).outPath;
            };
        };
      };

      users.users.jamie.extraGroups = [ "gamemode" ];
    };

}
