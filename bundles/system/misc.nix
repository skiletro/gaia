{ lib, ... }:
{
  nixos =
    { pkgs, ... }:
    {
      environment.defaultPackages = lib.mkForce [ pkgs.vim ];

      programs.nano.enable = false;

      services = {
        speechd.enable = false;
        dbus.implementation = "broker";
      };

      documentation = {
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
      };

      system = {
        disableInstallerTools = true; # remove generate, install, enter, option, version, build-vms, firewall
        tools.nixos-rebuild.enable = true; # but keep rebuild
      };
    };

  darwin = {
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

      activationScripts.postActivation.text = ''
        printf >&2 '%b' 'Activating settings \033[0;35mautomatically\e[0m...\n'
        sudo -u jamie /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
  };
}
