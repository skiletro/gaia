{
  home-manager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jetbrains.rider
        dotnet-sdk_8
        dotnet-sdk_10
      ];
    };
}
