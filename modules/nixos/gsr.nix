{
  config,
  lib,
  pkgs',
  ...
}:
let
  package = pkgs'.gpu-screen-recorder-ui.override {
    inherit (config.security) wrapperDir;
  };
in
{
  options = {
    programs.gpu-screen-recorder-ui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to install gpu-screen-recorder-ui and generate setcap
          wrappers for global hotkeys.
        '';
      };
      # TODO: create declarative settings section.
    };
  };

  config = lib.mkIf config.programs.gpu-screen-recorder-ui.enable {
    programs.gpu-screen-recorder.enable = lib.mkDefault true;

    environment.systemPackages = [ package ];

    systemd.packages = [ package ];

    security.wrappers."gsr-global-hotkeys" = {
      owner = "root";
      group = "root";
      capabilities = "cap_setuid+ep";
      source = lib.getExe' package "gsr-global-hotkeys";
    };

    systemd.user.services.gpu-screen-recorder-ui.wantedBy = [ "default.target" ]; # Start on startup
  };
}
