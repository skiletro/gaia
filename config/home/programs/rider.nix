{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.programs.rider.enable = lib.mkEnableOption "Rider and .NET SDKs";

  config = lib.mkIf config.erebus.programs.rider.enable {
    home.packages = with pkgs; [
      jetbrains.rider
      dotnet-sdk_10
    ];
  };
}
