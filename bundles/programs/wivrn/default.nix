{
  inputs,
  lib,
  ...
}: {
  nixos = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.nixpkgs-xr.nixosModules.nixpkgs-xr];

    services.wivrn = {
      enable = true;
      openFirewall = true;
      steam = {
        enable = true;
        inherit (config.programs.steam) package;
        importOXRRuntimes = true;
      };
      highPriority = true;
    };

    environment.systemPackages = with pkgs; [
      wayvr
      bs-manager
    ];

    system.tools.nixos-version.enable = true; # bs-manager requirement
  };

  home-manager = {config, ...}: let
    colors = config.lib.stylix.colors.withHashtag;
    palette = with colors; {
      primary = base0D;
      on_primary = base00;
      secondary = base09;
      on_secondary = base00;
      tertiary = base0C;
      on_tertiary = base00;
      danger = base08;
      on_danger = base00;
      background = base00;
      on_background = base05;
      background_variant = base01;
      on_background_variant = base04;
      background_contrast = base02;
      on_background_contrast = base05;
      outline = base03;
      shadow = base00;
      highlight = base05;
    };
  in {
    xdg.configFile = {
      "wayvr/palettes/stylix.json".text = lib.generators.toJSON {} palette;

      # Sort after the dashboard's saved config so Stylix remains authoritative.
      "wayvr/conf.d/zzz-nix.json5".text =
        lib.generators.toJSON {} {color_palette = "stylix.json";};
    };
  };
}
