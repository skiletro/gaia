{
  nixos = {pkgs, ...}: {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = false; # adds v4l2loopback kernel module
      plugins = with pkgs.obs-studio-plugins; [
        # keep-sorted start
        input-overlay
        obs-pipewire-audio-capture
        obs-vaapi # GStreamer VAAPI encoders; select in Advanced output mode
        obs-vkcapture
        wlrobs # screen capture wlroots based compositors
        # keep-sorted end
      ];
    };
  };
}
