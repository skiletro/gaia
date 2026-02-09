{
  lib,
  config,
  ...
}:
{
  options.programs.firefoxpwa.webapps = lib.mkOption {
    default = { };
    type =
      with lib.types;
      attrsOf (submodule {
        options = {
          url = lib.mkOption {
            type = str;
          };
          manifestUrl = lib.mkOption {
            type = str;
          };
          categories = lib.mkOption {
            type = listOf str;
          };
          icon = lib.mkOption {
            type = nullOr (either str path);
          };
        };
      });
  };

  config =
    let
      genUlid =
        string:
        "0123456789${
          lib.pipe (builtins.hashString "md5" string) [
            (builtins.substring 0 16)
            lib.toUpper
          ]
        }";

      mkWebapp =
        name: cfg:
        lib.nameValuePair "${genUlid cfg.url}" {
          sites."${genUlid cfg.manifestUrl}" = {
            inherit name;
            inherit (cfg) url manifestUrl;
            desktopEntry = {
              enable = true;
              inherit (cfg) categories icon;
            };
          };
        };
    in
    lib.mkIf config.programs.firefoxpwa.enable {
      programs.firefoxpwa = {
        profiles = lib.mapAttrs' mkWebapp config.programs.firefoxpwa.webapps;
        settings = {
          use_linked_runtime = true;
          runtime_use_portals = true;
          runtime_enable_wayland = true;
          always_patch = true;
        };
      };
    };
}
