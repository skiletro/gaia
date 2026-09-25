# The purpose of this file is to act as a sort of template to allow for quicker bundle creation.
{
  nixos = {pkgs, ...}: {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      printing = {
        enable = true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
          cnijfilter2
        ];
      };
    };
  };
}
