{
  lib,
  root,
}: file: args @ {
  bundleLib,
  config,
  ...
}: let
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
  categories = ["programs" "services" "system" "desktops"];
  category = builtins.elemAt (lib.init parts) 0;
  bundleName = lib.concatStringsSep "." (lib.init parts);
  rawRequires = moduleConfig.requires or [];
  validRequires = builtins.isList rawRequires && builtins.all builtins.isString rawRequires;
  resolveRequirement = requirement: let
    segments = lib.splitString "." requirement;
  in
    if builtins.length segments == 1 && builtins.head segments != ""
    then [category (builtins.head segments)]
    else if
      builtins.length segments
      == 2
      && builtins.elem (builtins.head segments) categories
      && lib.last segments != ""
    then segments
    else throw "invalid requirement '${requirement}' in bundle ${bundleName}; use <name> or <category>.<name>";
  requirements = map resolveRequirement rawRequires;
  enablePath = path: ["gaia"] ++ path ++ ["enable"];
  requirementEnabled = path: let
    optionPath = enablePath path;
  in
    lib.hasAttrByPath optionPath config
    && lib.getAttrFromPath optionPath config;
  assertionModule = {
    assertions = [
      {
        assertion = lib.all requirementEnabled requirements;
        message = "bundle ${bundleName} requires enabled bundle(s): ${lib.concatStringsSep ", " (map (path: "gaia.${lib.concatStringsSep "." path}.enable") requirements)}";
      }
    ];
  };
  moduleConfigWithoutMetadata = removeAttrs moduleConfig ["requires"];
  moduleConfigWithRequirements =
    if requirements == []
    then moduleConfigWithoutMetadata
    else
      moduleConfigWithoutMetadata
      // {
        nixos = (lib.toList (moduleConfigWithoutMetadata.nixos or [])) ++ [assertionModule];
      };
in
  if !valid
  then throw "bundle must be bundles/<category>/<name>/default.nix: ${toString file}"
  else if !validRequires
  then throw "requires in bundle ${bundleName} must be a list of strings"
  else bundleLib.mkEnableModule (["gaia"] ++ lib.init parts) moduleConfigWithRequirements
