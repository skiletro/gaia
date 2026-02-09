{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (pkgs.stdenvNoCC.hostPlatform) isDarwin isLinux;
in
{
  imports = [ inputs.zen.homeModules.twilight ];

  options.erebus.programs.zen.enable = lib.mkEnableOption "Zen Browser";

  config = mkIf config.erebus.programs.zen.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        ExtensionSettings = {
          "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/github-file-icons/latest.xpi";
            installation_mode = "force_installed";
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
      profiles.default = {
        id = 0;
        name = "default";
        settings = {
          "zen.welcome-screen.seen" = true;
          "zen.tabs.vertical.right-side" = false;
          "browser.toolbars.bookmarks.visiblity" = "always";
        };
      };
    };

    stylix.targets.zen-browser = {
      enable = mkIf isDarwin false; # disable if on mac
      profileNames = mkIf isLinux [ "default" ];
    };
  };
}
