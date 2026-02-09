{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.services.printing.enable = lib.mkEnableOption "Printing Services (CUPS, etc)";

  config = lib.mkIf config.erebus.services.printing.enable {
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
