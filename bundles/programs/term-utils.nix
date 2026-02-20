{ bundleLib, self', ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "term-utils" ] {

  home-manager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # keep-sorted start ignore_prefixes=pkgs'.
        dust # fancy du
        fd # find files
        ffmpeg
        file # identify files
        fzf # fuzzy finder
        gdu # disk utiliser
        heh # hex editor
        helix
        imagemagick
        jq # json processor
        just # make file but better
        libnotify # notifs through scripts
        ngrok # reverse proxy
        nixfmt # nix formatter
        ouch # cli for compressing and decompressing formats
        outfieldr # `tldr` client
        pik # Interactive pkill
        self'.packages.eos-helpers
        self'.packages.owo-sh
        unrar
        wget
        yt-dlp
        # keep-sorted end
      ];
    };

}
