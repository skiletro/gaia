{
  gaia.autoStart = ["gsr-ui launch-daemon"];

  nixos = {
    programs.gpu-screen-recorder = {
      enable = true;
      ui.enable = true;
    };
  };
}
