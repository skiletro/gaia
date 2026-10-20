{
  gaia.device.monitors = {
    builtin = {
      identity = "eDP-1";
      mode = {
        width = 2560;
        height = 1600;
        refresh = 60;
      };
      scale = 1.5;
      vrr = true;
    };
    external-ultrawide = {
      identity = "DP-1";
      mode = {
        width = 3440;
        height = 1440;
        refresh = 100;
      };
      scale = 1;
      vrr = true;
    };
  };
}
