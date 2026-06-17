{
  darwin.system = {
    defaults = {
      LaunchServices.LSQuarantine = false;

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

    activationScripts.postActivation.text = ''
      printf >&2 '%b' 'Activating settings \033[0;35mautomatically\e[0m...\n'
      sudo -u jamie /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}
