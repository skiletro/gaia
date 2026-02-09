{
  lib,
  inputs,
  self,
  withSystem,
  ...
}:
let
  nixosHosts = {
    eris = "x86_64-linux";
    keres = "aarch64-linux";
  };

  darwinHosts = {
    moirai = "aarch64-darwin";
  };

  mkNixos =
    hostName: system:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs self; };

      modules = with inputs; [
        # Our own configuration files
        self.nixosModules.erebus
        (import-tree (self + /hosts/${hostName}))

        # Modules
        home-manager.nixosModules.default
        stylix.nixosModules.stylix
        disko.nixosModules.default

        stylingModules
        (helperModules hostName system)
      ];
    };

  mkDarwin =
    hostName: system:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self; };

      modules = with inputs; [
        # Our own configuration files
        self.darwinModules.erebus
        (import-tree (self + /hosts/${hostName}))

        # Modules
        home-manager.darwinModules.home-manager
        stylix.darwinModules.stylix

        stylingModules
        (helperModules hostName system)
      ];
    };

  helperModules = hostName: system: {
    # Useful helper function that lets us use self' and inputs' in replace of self and inputs.
    # For example, instead of inputs.helix.packages.x86_64-linux.helix, we could do inputs'.helix.packages.helix!
    _module.args = withSystem system (
      {
        self',
        inputs',
        ...
      }:
      {
        inherit self' inputs';
        pkgs' = self'.packages;
      }
    );
    # Sets some stuff that we need that doesn't really make sense elsewhere.
    networking = { inherit hostName; };
    nixpkgs.hostPlatform = system;
  };

  # TODO: I should probably move this into its own flake parts module but it's fine here for now.
  stylingModules =
    {
      pkgs,
      pkgs',
      config,
      ...
    }:
    {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs'.base16-schemes}/share/themes/penumbra-dark-contrast-plus-plus.yaml";
        polarity = "dark";
        image =
          let
            wallpaper = pkgs.fetchurl {
              url = "https://w.wallhaven.cc/full/8x/wallhaven-8xe57j.jpg";
              sha256 = "036ld3x0y0frkjcspb1qfsjnqnxl5kq9nh2f0wrp54mlx7rmcmip";
            };
          in
          pkgs.runCommand "output.png" { }
            "${lib.getExe pkgs.lutgen} apply ${wallpaper} -o $out -- ${builtins.concatStringsSep " " config.lib.stylix.colors.toList}";
        fonts = {
          sansSerif = {
            package = pkgs.work-sans;
            name = "Work Sans";
          };
          serif = config.stylix.fonts.sansSerif; # Set serif font to the same as the sans-serif
          monospace = {
            package = pkgs'.liga-sf-mono-nerd-font;
            name = "Liga SFMono Nerd Font";
          };
          emoji = {
            package = pkgs'.apple-emoji;
            name = "Apple Color Emoji";
          };

          sizes = {
            applications = 10;
            desktop = 10;
            popups = 10;
            terminal = 12;
          };
        };
      };
    };
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs mkNixos nixosHosts;
    darwinConfigurations = lib.mapAttrs mkDarwin darwinHosts;
  };
}
