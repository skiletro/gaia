{
  home-manager = {pkgs, ...}: {
    home.packages = [
      (pkgs.delfin.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            substituteInPlace $out/share/applications/cafe.avery.Delfin.desktop \
              --replace-fail 'Name=Delfin' 'Name=Jellyfin' \
              --replace-fail 'Icon=cafe.avery.Delfin' 'Icon=jellyfin'
          '';
      }))
    ];
  };
}
