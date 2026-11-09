{inputs, ...}: {
  nixos = {
    imports = [inputs.bootvine.nixosModules.default];

    services.bootvine.enable = true;
  };
}
