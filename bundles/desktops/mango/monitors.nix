{
  lib,
  config,
  ...
}: {
  home-manager = {
    wayland.windowManager.mango.settings.monitor_rule = let
      renderMonitor = monitor: let
        selector =
          if builtins.isString monitor.identity
          then {name = "^${lib.escapeRegex monitor.identity}$";}
          else monitor.identity;
        rule =
          selector
          // monitor.mode
          // lib.optionalAttrs (monitor.scale != null) {inherit (monitor) scale;}
          // lib.optionalAttrs (monitor.position != null) monitor.position;
      in
        lib.concatStringsSep "," (lib.mapAttrsToList (name: value: "${name}:${toString value}") rule);
    in
      map renderMonitor (lib.attrValues config.gaia.device.monitors);
  };
}
