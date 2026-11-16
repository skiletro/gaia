{inputs', ...}: {
  nixos = {pkgs, ...}: let
    appimage-run = pkgs.appimage-run.override {
      extraPkgs = pkgs:
        with pkgs; [
          icu
          libxcrypt-legacy
          gtk3
          webkitgtk_4_1
        ];
    };
  in {
    nixpkgs.overlays = [
      (_final: prev: {
        # Keep archive-close errors from aborting DwarFS's stream pump.
        dwarfs = prev.dwarfs.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./dwarfs-extractor-close.patch];
        });
      })
    ];

    programs.appimage = {
      enable = true;
      binfmt = true;
      package = appimage-run;
    };
  };

  home-manager = {pkgs, ...}: {
    home.packages = [
      (inputs'.appimage-appmanager.packages.default.override {
        inherit (pkgs) dwarfs;
      })
    ];
  };
}
