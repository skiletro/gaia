{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.programs.libreoffice.enable =
    lib.mkEnableOption "Libre Office suite of office applications";

  config = lib.mkIf config.erebus.programs.libreoffice.enable {
    home.packages = lib.singleton (
      if pkgs.stdenvNoCC.hostPlatform.isDarwin then pkgs.libreoffice-bin else pkgs.libreoffice
    );
  };
}
