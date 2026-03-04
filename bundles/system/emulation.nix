{
  bundleLib,
  lib,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "system" "emulation" ] {

  nixos =
    { pkgs, ... }:
    {
      nix.settings.extra-sandbox-paths = [
        "/run/binfmt"
        (toString pkgs.qemu)
      ];

      boot.binfmt =
        with lib;
        let
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];

          otherPlatforms = filter (s: s != pkgs.stdenvNoCC.hostPlatform.system) platforms;

          getArch = flip pipe [
            (splitString "-")
            (flip elemAt 0)
          ];
        in
        {
          emulatedSystems = otherPlatforms;
          registrations = genAttrs otherPlatforms (s: {
            interpreter = "${pkgs.qemu}/bin/qemu-${getArch s}";
          });
        };
    };

  darwin =
    { pkgs, ... }:
    {
      nix.linux-builder = {
        enable = true;
        package = pkgs.darwin.linux-builder-x86_64;
        ephemeral = true;
        supportedFeatures = [
          "kvm"
          "benchmark"
          "big-parallel"
          "nixos-test"
        ];
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];
        config.virtualisation.cores = 6;
      };
    };

}
