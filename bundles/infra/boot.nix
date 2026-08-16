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
  };
}
