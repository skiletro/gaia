{
  inputs,
  self',
  lib,
  ...
}:
{
  home-manager =
    { pkgs, ... }:
    let
      inherit (pkgs.hostPlatform) isLinux isDarwin;
      equibop = self'.packages.equibop-patched;
    in
    {
      imports = [ inputs.nixcord.homeModules.nixcord ];

      home.packages = lib.mkIf isDarwin [ equibop ];

      programs.nixcord = {
        enable = true;
        discord = {
          vencord.enable = false;
          equicord.enable = true;
        };
        equibop = {
          enable = true;
          autoscroll.enable = true;
          package = if isLinux then equibop else null;
        };
        config = {
          useQuickCss = true;
          transparent = true;
          autoUpdate = true;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          plugins = {
            betterGifPicker.enable = true;
            ClearURLs.enable = true;
            crashHandler.enable = true;
            fakeNitro.enable = true;
            favoriteGifSearch.enable = true;
            fixSpotifyEmbeds.enable = true;
            fixYoutubeEmbeds.enable = true;
            limitMiddleClickPaste = {
              enable = true;
              limitTo = "never";
            };
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
