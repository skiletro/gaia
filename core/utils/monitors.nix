{lib, ...}: let
  inherit (lib) mkOption types;
  positiveNumber = types.addCheck types.number (value: value > 0);
  identityType = types.submodule {
    options = {
      make = mkOption {type = types.str;};
      model = mkOption {type = types.str;};
      serial = mkOption {type = types.str;};
    };
  };
  modeType = types.submodule {
    options = {
      width = mkOption {type = types.ints.positive;};
      height = mkOption {type = types.ints.positive;};
      refresh = mkOption {
        type = positiveNumber;
        description = "Refresh rate in Hz.";
      };
    };
  };
  positionType = types.submodule {
    options = {
      x = mkOption {type = types.int;};
      y = mkOption {type = types.int;};
    };
  };
in {
  options.gaia.device.monitors = mkOption {
    default = {};
    description = "Host-owned display rules; an empty set leaves outputs to compositor auto-discovery.";
    type = types.attrsOf (types.submodule {
      options = {
        identity = mkOption {
          type = types.either types.str identityType;
          description = "Connector name, or an exact make/model/serial identity.";
        };
        mode = mkOption {
          type = modeType;
        };
        scale = mkOption {
          type = types.nullOr positiveNumber;
          default = null;
        };
        position = mkOption {
          type = types.nullOr positionType;
          default = null;
          description = "Position in logical pixels; null uses compositor placement.";
        };
        vrr = mkOption {
          type = types.nullOr types.bool;
          default = null;
        };
      };
    });
  };
}
