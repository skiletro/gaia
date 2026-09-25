{inputs, ...}: {
  gaia.autoStart = ["equibop -m"];

  home-manager = {pkgs, ...}: {
    imports = [inputs.nixcord.homeModules.nixcord];

    programs.nixcord = {
      enable = true;
      discord = {
        enable = false;
        vencord.enable = false;
        equicord.enable = true;
      };
      equibop = {
        enable = true;
        autoscroll.enable = true;
        package = pkgs.equibop.overrideAttrs (_: {
          desktopItems = pkgs.makeDesktopItem {
            name = "equibop";
            desktopName = "Discord";
            exec = "equibop %U";
            icon = "discord";
            startupWMClass = "Equibop";
            genericName = "Internet Messenger";
            keywords = [
              "discord"
              "equibop"
              "electron"
              "chat"
            ];
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
          };
        });
      };
      config = {
        useQuickCss = true;
        transparent = true;
        autoUpdate = true;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;
        plugins = {
          betterGifPicker.enable = true;
          clearUrls.enable = true;
          crashHandler.enable = true;
          fakeNitro.enable = true;
          fixSpotifyEmbeds.enable = true;
          fixYoutubeEmbeds.enable = true;
          middleClickTweaks.enable = true;
          noSystemBadge.enable = true;
          messageLogger = {
            ignoreBots = true;
            ignoreSelf = true;
            collapseDeleted = true;
          };
          openInApp.enable = true;
          serverInfo.enable = true;
          unindent.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/discord" = "equibop.desktop";
    };
  };
}
