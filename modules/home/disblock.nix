{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.services.disblock;

  disblockOriginSettings = {
    # keep-sorted start block=yes newline_separated=yes
    active-now = {
      isBool = false;
      default = true;
      description = "Active Now column in friends list";
    };

    app-launcher = {
      isBool = false;
      default = false;
      description = "App launcher right of chat bar";
    };

    badges = {
      isBool = false;
      default = false;
      description = "Nitro and Booster badges on user profiles";
    };

    clan-tags = {
      isBool = false;
      default = true;
      description = "Clan tags next to the usernames";
    };

    gif-button = {
      isBool = false;
      default = false;
      description = "GIF button in chat bar";
    };

    hover-reaction-emoji = {
      isBool = false;
      default = true;
      description = "Emoji suggestions on message hover";
    };

    nameplates = {
      isBool = false;
      default = false;
      description = "Hide nameplates in the members list";
    };

    nitro-features = {
      isBool = false;
      default = false;
      description = "Settings menu Billing tab, Super React toggle, GIF Avatar";
    };

    profile-effects = {
      isBool = false;
      default = false;
      description = "Avatar decorations & profile effects";
    };

    server-settings-boost-tab = {
      isBool = false;
      default = false;
      description = "Server settings menu Boost tab";
    };

    settings-billing-header = {
      isBool = false;
      default = true;
      description = "Settings menu Billing Settings header";
    };

    settings-gift-inventory-tab = {
      isBool = false;
      default = true;
      description = "Settings menu Gift Inventory tab";
    };

    settings-nitro-tab = {
      isBool = false;
      default = false;
      description = "Settings menu Nitro tab";
    };

    settings-server-boost-tab = {
      isBool = false;
      default = false;
      description = "Settings menu Server Boost tab";
    };

    settings-subscriptions-tab = {
      isBool = false;
      default = false;
      description = "Settings menu Subscriptions tab";
    };

    sticker-button = {
      isBool = false;
      default = false;
      description = "Sticker button in chat bar";
    };

    super-reaction-hide-anim = {
      isBool = true;
      default = true;
      description = "Replace Super Reactions with a blink animation";
    };

    super-reactions = {
      isBool = false;
      default = false;
      description = "Hide super reactions entirely";
    };
    # keep-sorted end
  };

  mkSetting =
    _name: setting:
    lib.mkOption {
      inherit (setting) description default;
      type = lib.types.bool;
    };

  settingToCss =
    name: value:
    let
      setting = disblockOriginSettings.${name};

      prefix = if setting.isBool then "bool" else "display";

      css-value =
        if setting.isBool then
          lib.boolToString value
        else if value then
          "unset"
        else
          "none";
    in
    "--${prefix}-${name}: ${css-value};";
in
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  options.services.disblock = {
    enable = lib.mkEnableOption "Disblock Origin";
    settings = lib.mapAttrs mkSetting disblockOriginSettings;
  };

  config = lib.mkIf cfg.enable {
    programs.nixcord = {
      config = {
        themeLinks = lib.singleton "https://raw.codeberg.page/AllPurposeMat/Disblock-Origin/DisblockOrigin.theme.css";
        useQuickCss = true;
      };
      quickCss =
        # css
        ''
          :root {
            ${lib.pipe cfg.settings [
              (lib.mapAttrsToList settingToCss)
              (lib.concatStringsSep "\n  ")
            ]}
          }
        '';
    };
  };
}
