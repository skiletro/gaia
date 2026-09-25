{
  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.rustdesk-flutter];
  };
}
