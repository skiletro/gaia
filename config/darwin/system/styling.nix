{ lib, config, ... }:
{
  home-manager.sharedModules = lib.singleton (
    {
      lib,
      config,
      ...
    }:
    {
      home.activation."setWallpaper" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Setting wallpaper..."
        /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${config.stylix.image}\""
      '';
    }
  );

  system.defaults =
    let
      aerospaceIsEnabled = config.erebus.services.aerospace.enable;
      ifTiling = bool: if aerospaceIsEnabled then bool else !bool;
    in
    {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        NSStatusItemSpacing = 8; # default=12
        NSStatusItemSelectionPadding = 6; # default=6
        _HIHideMenuBar = false;
        NSAutomaticWindowAnimationsEnabled = ifTiling false;
      };
      spaces.spans-displays = ifTiling true;
      dock.expose-group-apps = ifTiling true;
    };
}
