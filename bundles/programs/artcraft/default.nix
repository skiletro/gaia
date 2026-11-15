{
  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # keep-sorted start
      photocraft # Raster image editing
      vectorcraft # Vector image editing
      # keep-sorted end
    ];
  };
}
