{
  bundleLib,
  inputs,
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "wivrn"] {
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
  };
}
