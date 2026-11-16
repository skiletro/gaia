{
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.delfin];

    xdg.dataFile."applications/cafe.avery.Delfin.desktop".source = pkgs.runCommand "cafe.avery.Delfin.desktop" {} ''
      install -m644 ${pkgs.delfin}/share/applications/cafe.avery.Delfin.desktop $out
      substituteInPlace $out \
        --replace-fail 'Name=Delfin' 'Name=Jellyfin' \
        --replace-fail 'Icon=cafe.avery.Delfin' 'Icon=jellyfin'
    '';
  };
}
