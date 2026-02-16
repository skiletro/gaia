{
  bundleLib,
  inputs',
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "wivrn" ] {

  nixos =
    { pkgs, ... }:
    {
      services.wivrn =
        let
          inherit (inputs'.nixpkgs-xr.packages) wivrn xrizer opencomposite;
        in
        {
          enable = true;
          package = wivrn.override {
            ovrCompatSearchPaths = "${xrizer}/lib/xrizer:${opencomposite}/lib/opencomposite";
          };
          openFirewall = true;
          defaultRuntime = true;
          steam.importOXRRuntimes = true;
          highPriority = true;
        };

      environment.systemPackages = with pkgs; [
        android-tools
        wayvr
      ];

    };

  home-manager =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    {
      # This assumes a WiVRn configuration
      xdg.configFile."openxr/1/active_runtime.json".source =
        "${osConfig.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";

      xdg.configFile."openvr/openvrpaths.vrpath".text =
        let
          steam = "${config.xdg.dataHome}/Steam";
        in
        builtins.toJSON {
          version = 1;
          jsonid = "vrpathreg";
          external_drivers = null;
          config = [ "${steam}/config" ];
          log = [ "${steam}/logs" ];
          "runtime" = lib.singleton "${pkgs.xrizer}/lib/xrizer";
        };
    };

  darwin = throw "gaia: 'wivrn' is incompatible with nixos.";

}
