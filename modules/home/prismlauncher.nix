{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption;
  inherit (lib.types) listOf package;
in
{
  options.programs.prismlauncher' = {
    enable = mkEnableOption "Prism Launcher";
    jdks = mkOption {
      type = listOf package;
      default = [
        pkgs.jdk21
        pkgs.jdk17
        pkgs.jdk8
      ];
    };
  };

  config = lib.mkIf config.programs.prismlauncher'.enable {
    home.packages = lib.singleton (
      pkgs.prismlauncher.override {
        inherit (config.programs.prismlauncher') jdks;
      }
    );
  };
}
