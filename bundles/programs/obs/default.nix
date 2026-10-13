{
  nixos = {pkgs, ...}: {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
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
