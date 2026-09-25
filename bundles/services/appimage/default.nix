{
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
    programs.appimage = {
      enable = true;
      binfmt = true;
      package = appimage-run;
    };

    environment.systemPackages = [
      (pkgs.gearlever.override {
        inherit appimage-run;
      })
    ];
  };
}
