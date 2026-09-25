{
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
