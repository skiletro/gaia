{
  nixos = {pkgs, ...}: {
    services.udev.packages = [
      pkgs.qmk-udev-rules
    ];
  };

  home-manager = {pkgs, ...}: {
    home.packages = [
      (
        pkgs.vial.override {
          appimageTools =
            pkgs.appimageTools
            // {
              wrapType2 = args:
                pkgs.appimageTools.wrapType2 (args
                  // {
                    # Vial's bundled Qt xcb plugin needs this in its AppImage FHS environment.
                    extraPkgs = pkgs: [pkgs.libgpg-error];
                  });
            };
        }
      )
    ];
  };
}
