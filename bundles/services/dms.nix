{ bundleLib, inputs, ... }:
bundleLib.mkEnableModule [ "gaia" "services" "dms" ] {

  nixos = {
    imports = [ inputs.dms.nixosModules.dank-material-shell ];

    programs.dank-material-shell = {
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enable = true;
      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = false; # we use stylix instead
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
    };
  };

  home-manager =
    { config, ... }:
    {
      imports = with inputs; [
        dms.homeModules.dank-material-shell
        dms-plugin-registry.modules.default
      ];

      programs.dank-material-shell = {
        enable = true;
        managePluginSettings = true;
        plugins = {
          dankKDEConnect.enable = true;
          volumeMixer.enable = true;
        };
        settings = {
          fontFamily = config.stylix.fonts.sansSerif.name;
          monoFontFamily = config.stylix.fonts.monospace.name;

          cornerRadius = 6;
          showSeconds = false;
          useFahrenheit = false;
          use24HourClock = false;
          padHours12Hour = true;

          modalDarkenBackground = false;
          enableRippleEffects = false;

          osdMediaPlaybackEnabled = false;

          animationSpeed = 4;
          customAnimationDuration = 400; # ms
          wallpaperFillMode = "Fill";
          blurredWallpaperLayer = false;
          blurWallpaperOnOverview = false;
          showLauncherButton = true;
          showWorkspaceSwitcher = true;
          showFocusedWindow = true;
          showWeather = false;
          weatherEnabled = false;
          showMusic = true;
          showClipboard = true;
          showCpuUsage = true;
          showMemUsage = true;
          showCpuTemp = true;
          showGpuTemp = true;
          selectedGpuIndex = 0;
          enabledGpuPciIds = [ ];
          showSystemTray = true;
          showClock = true;
          showNotificationButton = true;
          showBattery = true;
          showControlCenterButton = true;
          showCapsLockIndicator = true;
          controlCenterShowNetworkIcon = true;
          controlCenterShowBluetoothIcon = true;
          controlCenterShowAudioIcon = true;
          controlCenterShowAudioPercent = false;
          controlCenterShowVpnIcon = true;
          controlCenterShowBrightnessIcon = false;
          controlCenterShowBrightnessPercent = false;
          controlCenterShowMicIcon = false;
          controlCenterShowMicPercent = false;
          controlCenterShowBatteryIcon = false;
          controlCenterShowPrinterIcon = false;
          showPrivacyButton = true;
          privacyShowMicIcon = false;
          privacyShowCameraIcon = false;
          privacyShowScreenShareIcon = false;

          lockScreenShowPowerActions = false;
          lockScreenShowSystemIcons = true;
          lockScreenShowTime = true;
          lockScreenShowDate = true;
          lockScreenShowProfileImage = false;
          lockScreenShowPasswordField = false;
          lockScreenShowMediaPlayer = true;
          lockScreenPowerOffMonitorsOnLock = false;

          # Screen settings
          screenPreferences = {
            dankBar = [
              "all"
            ];
            wallpaper = [ ];
          };
          showOnLastDisplay = {
            dankBar = true;
          };

          # Icon substitutions
          appIdSubstitutions = [
            {
              pattern = "Spotify";
              replacement = "spotify";
              type = "exact";
            }
            {
              pattern = ''^steam_app_(\\d+)$'';
              replacement = "steam_icon_$1";
              type = "regex";
            }
            {
              pattern = "Proton Mail";
              replacement = "proton-mail";
              type = "exact";
            }
            {
              pattern = "Proton Pass";
              replacement = "proton-pass";
              type = "exact";
            }
          ];

          # Dock settings
          showDock = true;
          dockAutoHide = false;
          dockSmartAutoHide = true;
          dockGroupByApp = true;
          dockOpenOnOverview = false;
          dockPosition = 1; # right hand side
          dockSpacing = 15; # %
          dockMargin = 10;
          dockIconSize = 45;
          dockIndicatorStyle = "line"; # one of "line", "circle"

          # Frame
          frameEnabled = true;
          frameThickness = 2;
          frameRounding = 12;
          frameColor = "#000000";
          frameBarSize = 32;

          # Bar settings
          barConfigs =
            let
              w = id: {
                inherit id;
                enabled = true;
              };
              spacer = {
                id = "spacer";
                enabled = true;
                size = 5;
              };
            in
            [
              {
                id = "default";
                name = "Main Bar";
                enabled = true;
                position = 2; # left hand side
                screenPreferences = [
                  "all"
                ];
                showOnLastDisplay = true;
                leftWidgets = [
                  (w "workspaceSwitcher")
                ];
                centerWidgets = [
                  (w "clock")
                  # TODO: figure out a way to add secrets pertaining to weather
                  # spacer
                  # (w "weather")
                ];
                rightWidgets = [
                  (w "music")
                  (w "dankKDEConnect")
                  spacer
                  (w "systemTray")
                  spacer
                  (w "notificationButton")
                  (w "volumeMixer")
                  (
                    (w "controlCenterButton")
                    // {
                      showAudioIcon = false;
                      showAudioPercent = false;
                    }
                  )
                  spacer
                ];
                spacing = 5;
                innerPadding = 4;
                bottomGap = 0;
                transparency = 0;
                widgetTransparency = 0;
                squareCorners = true;
                noBackground = false;
                gothCornersEnabled = false;
                gothCornerRadiusOverride = false;
                gothCornerRadiusValue = 54;
                borderEnabled = false;
                borderColor = "surfaceText";
                borderOpacity = 1;
                borderThickness = 1;
                fontScale = 1;
                autoHide = false;
                autoHideDelay = 250;
                openOnOverview = false;
                visible = true;
                popupGapsAuto = true;
                popupGapsManual = 4;
                maximizeDetection = false;
                widgetOutlineEnabled = false;
                widgetOutlineThickness = 2;
                widgetOutlineColor = "surfaceText";
              }
            ];
          showWorkspaceApps = true;
          showWorkspaceIndex = true;
          maxWorkspaceIcons = 5;
          groupWorkspaceApps = false;

          # Control center settings
          controlCenterWidgets =
            let
              w = id: {
                inherit id;
                width = 50;
                enabled = true;
              };
              du = instanceId: mountPath: w "diskUsage" // { inherit instanceId mountPath; };
            in
            [
              (w "volumeSlider")
              (w "inputVolumeSlider")
              (w "audioOutput")
              (w "audioInput")
              (w "bluetooth")
              (du "mktvkfz3tysbvmtwsns9t6c9d1ya5" "/")
            ];

          # Power menu
          powerMenuDefaultAction = "restart";
          powerActionHoldDUration = 0.75;

          # Idle
          acLockTimeout = 180;
          acPostLockMonitorTimeout = 900;
          lockBeforeSuspend = true;
        };
        session = {
          nightModeEnabled = true;
          nightModeTemperature = 4500;
          nightModeHighTemperature = 6500;
          nightModeAutoEnabled = true;
          nightModeAutoMode = "time";
          nightModeStartHour = 22;
          nightModeStartMinute = 0;
          nightModeEndHour = 6;
          nightModeEndMinute = 0;
        };
      };
    };

  darwin = throw "gaia: 'dms' is incompatible with macos.";

}
