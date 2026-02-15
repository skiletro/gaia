{ lib, inputs', ... }:
{
  home-manager =
    { pkgs, ... }:
    {
      home.packages = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin [ pkgs.raycast ];

      programs.vicinae = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux {
        enable = true;
        systemd.enable = true;
        extensions = with inputs'.vicinae-extensions.packages; [
          # keep-sorted start
          bluetooth
          # TODO: fuzzy-files (requires goldfish which isnt packaged rn)
          nix
          # keep-sorted end
        ];
        settings = {
          close_on_focus_loss = true;
          providers = {
            "@Gelei/bluetooth-0".preferences.connectionToggleable = true;
            "@knoopx/nix-0".entrypoints = {
              flake-packages.enabled = false;
              pull-requests.enabled = false;
            };
            core.entrypoints = {
              keybind-settings.enabled = false;
              report-bug.enabled = false;
              sponsor.enabled = false;
            };
            clipboard.enabled = false;
            developer.enabled = false;
            manage-shortcuts.enabled = false;
            power.enabled = false;
            theme.enabled = false;
            applications = {
              preferences.launchPrefix = "uwsm app -- ";
              # format is the name of the .desktop file, without the suffix (case sensitive)
              # e.g., `org.qbittorrent.qBittorrent.desktop` would be `org.qbittorrent.qBittorrent`
              entrypoints = lib.genAttrs' [
                # keep-sorted start
                "Helix"
                "Steam Linux Runtime 1.0 (scout)"
                "Steam Linux Runtime 2.0 (soldier)"
                "Steam Linux Runtime 3.0 (sniper)"
                "Steam Linux Runtime 4.0"
                "btop"
                "hyprprop"
                "iamb"
                "khal"
                "nixos-manual"
                "org.kde.kdeconnect.nonplasma"
                "org.kde.kdeconnect.sms"
                "qt5ct"
                "qt6ct"
                "startcenter"
                "steamtinkerlaunch"
                "uuctl"
                "vicinae"
                "yazi"
                # keep-sorted end
              ] (n: lib.nameValuePair n { enabled = false; });
            };
          };
        };
      };
    };
}
