{
  config,
  lib,
  self,
  pkgs,
  ...
}:
{
  imports = [ self.homeModules.prismlauncher ];

  options.erebus.programs.prismlauncher.enable = lib.mkEnableOption "Prism Launcher";

  config = lib.mkIf config.erebus.programs.prismlauncher.enable {
    programs.prismlauncher' = {
      enable = true;
      jdks = with pkgs; [
        graalvmPackages.graalvm-oracle_17
        jdk8
        temurin-jre-bin # 21
      ];
    };
  };
}
