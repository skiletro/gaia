{self', ...}: {
  home-manager = {
    home.packages = [self'.packages.romp];
  };
}
