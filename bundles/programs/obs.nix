{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "obs"] {
  nixos = {pkgs, ...}: {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        obs-pipewire-audio-capture
      ];
    };
  };
}
