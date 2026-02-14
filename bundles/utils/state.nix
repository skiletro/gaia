{ lib, config, ... }:
{
  options.gaia.state = {
    system = lib.mkOption {
      description = "Sets the system state version";
      type = with lib.types; either int str;
      default = null;
    };
    home = lib.mkOption {
      description = "Sets the system state version";
      type = lib.types.str;
      default = config.gaia.state.system;
    };
  };

  config = with config.gaia.state; {
    nixos.system.stateVersion = system;
    darwin.system.stateVersion = system;
    home-manager.home.stateVersion = home;
  };
}
