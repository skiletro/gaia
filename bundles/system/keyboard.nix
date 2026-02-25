{
  darwin = {
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      defaults = {
        hitoolbox.AppleFnUsageType = "Do Nothing";
        NSGlobalDomain = {
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSWindowShouldDragOnGesture = true; # move windows by holding ⌃+⌘ and dragging
        };
      };
    };
  };
}
