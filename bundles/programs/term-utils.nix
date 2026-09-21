{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "term-utils"] {
  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # keep-sorted start
      android-tools
      brightnessctl
      ffmpeg
      imagemagick
      yt-dlp
      # keep-sorted end
    ];
  };
}
