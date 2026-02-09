{ config, lib, ... }:
{
  options.erebus.services.jankyborders.enable = lib.mkEnableOption "Jankyborders";

  config = lib.mkIf config.erebus.services.jankyborders.enable {
    home-manager.sharedModules = lib.singleton {
      services.jankyborders = {
        enable = true;
        settings = with config.lib.stylix.colors; {
          style = "square";
          width = "4.0";
          hidpi = true;
          blacklist =
            let
              list = [
                "Steam"
                "FaceTime"
                "Screen Sharing"
              ];
            in
            "\"${builtins.concatStringsSep "," list}\"";
          active_color = lib.mkForce "0xff${lib.toLower base08}";
          inactive_color = lib.mkForce "0xff${lib.toLower base00}";
        };
      };
    };
  };
}
