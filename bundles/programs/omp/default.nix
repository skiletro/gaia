{
  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      omp
      rtk
    ];
  };
}
