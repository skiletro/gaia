{self', ...}: {
  home-manager = {config, ...}: {
    home.packages = [
      (self'.packages.photocraft.override {
        stylixColors = config.lib.stylix.colors;
        stylixFonts = {
          inherit (config.stylix.fonts) sansSerif monospace;
        };
      })
    ];
  };
}
