{
  bundleLib,
  lib,
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "gsr"] {
  gaia.autoStart = ["gsr-ui launch-hide-announce"];

  nixos = {
    self',
    config,
    ...
  }: let
    package = self'.packages.gpu-screen-recorder-ui.override {
      inherit (config.security) wrapperDir;
    };
  in {
    programs.gpu-screen-recorder.enable = lib.mkDefault true;

    environment.systemPackages = [package];

    security.wrappers."gsr-global-hotkeys" = {
      owner = "root";
      group = "root";
      capabilities = "cap_setuid+ep";
      source = lib.getExe' package "gsr-global-hotkeys";
    };
  };
}
