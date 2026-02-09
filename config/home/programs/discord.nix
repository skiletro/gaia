{
  lib,
  config,
  self,
  pkgs,
  pkgs',
  ...
}:
let
  inherit (pkgs.stdenvNoCC.hostPlatform) isLinux isDarwin;
  ifLinux = bool: if isLinux then bool else !bool;
in
{
  imports = [ self.homeModules.disblock ];

  options.erebus.programs.discord.enable = lib.mkEnableOption "Discord (+ Nixcord/Vencord)";

  # TODO: submit PR to nixcord to make assertion a bit nicer.
  config = lib.mkIf config.erebus.programs.discord.enable {
    home.packages = [ (lib.mkIf isDarwin pkgs'.equibop-patched) ]; # workaround for nixcord

    programs.nixcord = {
      enable = true;
      discord = {
        enable = false;
        vencord.enable = ifLinux false;
        equicord.enable = ifLinux true;
      };
      equibop = {
        enable = true;
        autoscroll.enable = true;
        package = if isLinux then pkgs'.equibop-patched else null; # workaround for nixcord
      };
      config = {
        useQuickCss = true;
        themeLinks = lib.optional pkgs.stdenvNoCC.hostPlatform.isLinux "https://chloecinders.github.io/visual-refresh-compact-title-bar/browser.css";
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

    services.disblock = {
      enable = true;
      settings = {
        gif-button = true;
        active-now = false;
        clan-tags = false;
        settings-billing-header = false;
        settings-gift-inventory-tab = false;
      };
    };

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/discord" = "equibop.desktop";
    };

    xdg.autostart.entries = lib.mkIf isLinux (
      config.lib.erebus.autostartEntry "Discord Silent" "${lib.getExe config.programs.nixcord.finalPackage.equibop} --start-minimized"
    );
  };
}
