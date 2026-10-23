{lib, ...}: {
  nixos = {pkgs, ...}: {
    services = {
      gnome = {
        core-apps.enable = true;
        gnome-keyring.enable = true;
      };
      gvfs.enable = true;
      tumbler.enable = true;
      udisks2.enable = true;
    };
    environment.pathsToLink = ["share/thumbnailers"];
    environment.gnome.excludePackages = lib.mkDefault (
      with pkgs; [
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
        gnome-disk-utility
        gnome-font-viewer
        gnome-maps
        gnome-music
        gnome-software
        gnome-system-monitor
        gnome-tour
        gnome-weather
        orca
        papers
        seahorse
        showtime
        simple-scan
        snapshot
        totem
        yelp
        # keep-sorted end
      ]
    );

    environment.systemPackages = with pkgs; [
      # keep-sorted start
      file-roller # archive manager (just use ouch on cli)
      gparted
      imv
      libheif # nautilus heic img preview
      libheif.out # nautilus heic img preview
      # keep-sorted end
    ];
  };

  home-manager = {
    programs.mpv.enable = true;
    programs.zathura.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        imageViewer = "imv.desktop";
        videoPlayer = "mpv.desktop";
        audioPlayer = "mpv.desktop";
      in {
        # keep-sorted start
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "audio/flac" = audioPlayer;
        "image/gif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/webp" = imageViewer;
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "text/plain" = "org.gnome.TextEditor.desktop";
        "video/mov" = videoPlayer;
        "video/mp4" = videoPlayer;
        # keep-sorted end
      };
    };
  };
}
