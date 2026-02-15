{
  nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.libreoffice ];
    };

  darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.libreoffice-bin ];
    };
}
