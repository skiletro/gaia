{
  lib,
  config,
  pkgs,
  pkgs',
  ...
}:
{
  options.erebus.profiles.terminal.enable =
    lib.mkEnableOption "terminal applications that are generally wanted on all systems, but aren't required like the `base` profile.";

  config = lib.mkIf config.erebus.profiles.terminal.enable {
    erebus.programs = {
      # keep-sorted start
      beets.enable = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux true;
      broot.enable = true;
      btop.enable = true;
      carapace.enable = true;
      direnv.enable = true;
      fastfetch.enable = true;
      fish.enable = true;
      git.enable = true;
      helix.enable = true;
      nu.enable = true;
      tmux.enable = true;
      wakatime.enable = true;
      yazi.enable = true;
      # keep-sorted end
    };

    home.packages = with pkgs; [
      # keep-sorted start ignore_prefixes=pkgs'.
      caligula # iso burner
      dust # fancy du
      pkgs'.eos-cli
      pkgs'.eos-helpers
      fd # find files
      ffmpeg
      file # identify files
      fzf # fuzzy finder
      gdu # disk utiliser
      heh # hex editor
      iamb # matrix
      imagemagick
      jq # json processor
      just # make file but better
      libnotify # notifs through scripts
      ngrok # reverse proxy
      nixfmt # nix formatter
      ouch # cli for compressing and decompressing formats
      outfieldr # `tldr` client
      pkgs'.owo-sh
      pik # Interactive pkill
      unrar
      wget
      yt-dlp
      # keep-sorted end
    ];
    home.shellAliases = {
      n = "cd ~/Projects/erebus";
    };
  };
}
