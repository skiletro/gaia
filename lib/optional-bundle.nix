{
  lib,
  root,
}: file: args @ {bundleLib, ...}: let
  relative = lib.removePrefix "${toString root}/" (toString file);
  parts = lib.splitString "/" relative;
  valid =
    lib.hasPrefix "${toString root}/" (toString file)
    && builtins.length parts == 3
    && lib.last parts == "default.nix";
  imported = import file;
  moduleArgs = lib.mapAttrs (name: _: args.${name} or args.config._module.args.${name}) (builtins.functionArgs imported);
  moduleConfig =
    if builtins.isFunction imported
    then imported moduleArgs
    else imported;
in
  if !valid
  then throw "bundle must be bundles/<category>/<name>/default.nix: ${toString file}"
  else bundleLib.mkEnableModule (["gaia"] ++ lib.init parts) moduleConfig
