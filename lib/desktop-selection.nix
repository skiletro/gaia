{lib}: let
  enabled = desktops: lib.filter (name: desktops.${name}.enable) (lib.attrNames desktops);
  default = desktops: let
    names = enabled desktops;
  in
    if builtins.length names == 1
    then builtins.head names
    else null;
  single = desktops: let
    name = default desktops;
  in
    if name != null
    then name
    else throw "gaia.system.autologin.enable requires exactly one enabled gaia.desktops.<name>.enable";
in {inherit enabled default single;}
