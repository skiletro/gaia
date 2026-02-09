{
  lib,
  pkgs,
  ...
}:
{
  lib.erebus.autostartEntry =
    entryName: entryCommand:
    let
      name = lib.toCamelCase entryName;
    in
    lib.singleton (
      (pkgs.makeDesktopItem {
        desktopName = entryName;
        inherit name;
        destination = "/";
        exec = entryCommand;
        noDisplay = true;
      })
      + /${name}.desktop
    );

  xdg = {
    enable = true;
    autostart.enable = true;
  };
}
