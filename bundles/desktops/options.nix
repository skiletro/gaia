{ lib, ... }:
{
  options.gaia.desktop = lib.mkOption {
    description = "Sets the desktop environment to use";
    default = "hyprland";
    type = lib.types.nullOr (
      lib.types.enum (
        lib.pipe (builtins.readDir ./.) [
          (lib.filterAttrs (name: _: name != "options"))
          lib.attrNames
          (map (name: lib.removeSuffix ".nix" name))
        ]
      )
    );
  };
}
