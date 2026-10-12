{inputs', ...}: {
  home-manager = {
    home.packages = with inputs'.artcraft.packages; [
      # keep-sorted start
      filmcraft # Video editing
      photocraft # Raster image editing
      vectorcraft # Vector image editing
      # keep-sorted end
    ];
  };
}
