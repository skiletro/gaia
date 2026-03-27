{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "suite" ] {

  nixos =
    { pkgs, ... }:
    {
      services = {
        gnome = {
          core-apps.enable = true;
          gnome-keyring.enable = true;
        };
        gvfs.enable = true;
        tumbler.enable = true;
      };
      environment.pathsToLink = [ "share/thumbnailers" ];
      environment.gnome.excludePackages = lib.mkDefault (
        with pkgs;
        [
          # keep-sorted start
          baobab
          epiphany
          evince
          geary
          gnome-calendar
          gnome-characters
          gnome-clocks
          gnome-connections
          gnome-console
          gnome-contacts
          gnome-font-viewer
          gnome-maps
          gnome-music
          gnome-software
          gnome-system-monitor
          gnome-tour
          gnome-weather
          orca
          seahorse
          simple-scan
          snapshot
          totem
          yelp
          # keep-sorted end
        ]
      );

      environment.systemPackages = with pkgs; [
        # keep-sorted start
        adwaita-icon-theme # fixes some missing icons
        adwaita-icon-theme-legacy # fixes some missing icons
        file-roller # archive manager (just use ouch on cli)
        gapless # music player
        gnome-disk-utility
        gnome-logs
        libheif # nautilus heic img preview
        libheif.out # nautilus heic img preview
        pwvucontrol
        # keep-sorted end
      ];
    };

  home-manager = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/pdf" = "org.gnome.Papers.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "audio/flac" = "org.gnome.Decibels.desktop";
        "video/mp4" = "org.gnome.Showtime.desktop";
        "video/mov" = "org.gnome.Showtime.desktop";
        "text/plain" = "org.gnome.TextEditor.desktop";
      };
    };
  };

}
