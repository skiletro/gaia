{ lib, config, ... }:
lib.mkIf (config.gaia.desktop == "grid") {

  gaia.programs.raycast.enable = true;

  nixos = throw "gaia: 'grid' is incompatible with nixos. try using 'hyprland' instead.";

  darwin = {
    homebrew.casks = [
      "iina"
      "intellidock"
      "grid"
    ];

    system.activationScripts."grid-autostart".text =
      # zsh
      ''
        open -a IntelliDock.app
        open -a Grid.app
      '';
  };

}
