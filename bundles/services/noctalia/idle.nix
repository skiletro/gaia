{
  home-manager = {
    programs.noctalia.settings = {
      # Idle behaviour (autolocking)
      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        pre_action_fade_seconds = 5;
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 600.0;
          };
          lock-and-suspend = {
            action = "lock_and_suspend";
            enabled = false;
            timeout = 900.0;
          };
          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 660.0;
          };
        };
      };

      # Lockscreen
      lockscreen = {
        blurred_desktop = true;
        fingerprint = false;
        transition = ["wipe"];
        transition_duration = 500; # ms
      };
    };
  };
}
