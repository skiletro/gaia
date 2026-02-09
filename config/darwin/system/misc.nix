{
  system = {
    defaults = {
      LaunchServices.LSQuarantine = false; # gets rid of the "are you sure" msg when opening new app
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.SoftwareUpdate" = {
          "MajorOSUserNotificationDate" = "2040-01-01 20:00:00 +0000";
          "UserNotificationDate" = "2040-01-01 20:00:00 +0000";
        };
      };
    };

    activationScripts."activate-settings-automatically".text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}
