{lib, ...}: {
  nixos = {
    config,
    pkgs,
    ...
  }: {
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

      loader = {
        limine = {
          enable = true;

          # Each retained generation copies its kernel + initrd (~85 MiB)
          # into the 512 MiB ESP. The nixpkgs default (null = unlimited)
          # fills /boot once several generations exist.
          maxGenerations = 6;

          style = {
            # stylix sets wallpapers = [ image ]; list options merge by
            # concatenation, so mkForce is required to actually clear it.
            wallpapers = lib.mkForce [];

            graphicalTerminal = {
              margin = 0;
              marginGradient = 0;
            };

            interface = with config.lib.stylix.colors; {
              brandingColor = base0D; # iris
              helpColor = base0C; # foam
              helpColorBright = base0B; # pine
            };
          };
        };

        efi.canTouchEfiVariables = true;
      };
    };

    stylix.targets.limine.enable = true;
  };
}
