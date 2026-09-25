{
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.supersonic];
  };
}
