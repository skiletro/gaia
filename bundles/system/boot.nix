{ lib, inputs, ... }:
{
  nixos =
    { pkgs, ... }:
    {
      boot = {
        kernelPackages = lib.mkDefault (
          if pkgs.stdenvNoCC.hostPlatform.isx86_64 then
            pkgs.cachyosKernels.linuxPackages-cachyos-latest
          else
            pkgs.linuxPackages
        );

        loader = {
          limine.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };

      nixpkgs.overlays = lib.singleton inputs.cachyos-kernel.overlays.pinned;
    };
}
