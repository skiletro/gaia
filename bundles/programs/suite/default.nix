{lib, ...}: {
  nixos = {pkgs, ...}: {
    services = {
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true; # nautilus space preview
      };
      gvfs.enable = true;
      tumbler.enable = true;
      udisks2.enable = true;
    };

    programs.nautilus-open-any-terminal.enable = true;

    environment = {
      pathsToLink = [
        "/share/thumbnailers"
        "/share/nautilus-python/extensions"
      ];
      systemPackages = with pkgs; [
        # keep-sorted start
        file-roller # archive manager (just use ouch on cli)
        gnome-calculator
        gnome-font-viewer
        gnome-logs
        gnome-text-editor
        gparted # partition manager
        imv # image viewer
        nautilus
        nautilus-python
        # keep-sorted end
      ];
      sessionVariables = {
        # The upstream terminal-extension module exposes only nautilus-python here,
        # hiding every other extension linked into the system profile.
        # Follow the active generation even when the desktop session predates a switch.
        NAUTILUS_4_EXTENSION_DIR = lib.mkForce "/run/current-system/sw/lib/nautilus/extensions-4";
      };
    };
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
