{ pkgs, ... }:
{
  erebus.profiles = {
    base.enable = true;
    gaming.enable = true;
    graphical.enable = true;
    terminal.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # keep-sorted start
    calibre-no-speech
    fsearch # Fast File Search
    godot_4 # Godot Engine
    handbrake # Video Encoder
    obs-studio # Screen Recording and Broadcast Suite
    plex-htpc
    tenacity # Audio Editor
    video-trimmer # Trims Videos
    vlc # Media Player, mostly used for m3u files
    # keep-sorted end
  ];
}
