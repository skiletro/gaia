{
  nixos = {pkgs, ...}: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        curl
        expat
        at-spi2-atk
        atk
        cairo
        cups
        dbus
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libGL
        libuuid
        libxkbcommon
        mesa
        nspr
        pango
        pipewire
        udev
        libx11
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        libxcb-keysyms
        alsa-lib
      ];
    };
  };
}
