{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "gsr" ] {

  nixos =
    { self', config, ... }:
    let
      package = self'.packages.gpu-screen-recorder-ui.override {
        inherit (config.security) wrapperDir;
      };
    in
    {
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

  darwin = throw "gaia: 'gsr' is incompatible with macos.";

}
