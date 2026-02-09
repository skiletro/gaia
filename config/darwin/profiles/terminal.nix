{
  lib,
  config,
  ...
}:
{
  options.erebus.profiles.terminal.enable =
    lib.mkEnableOption "terminal applications that are generally wanted on all systems, but aren't required like the `base` profile.";

  config = lib.mkIf config.erebus.profiles.terminal.enable {
    home-manager.sharedModules = lib.singleton {
      erebus.profiles.terminal.enable = true;
    };
  };
}
