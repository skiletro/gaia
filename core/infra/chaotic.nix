{inputs, ...}: {
  nixos = {
    imports = [inputs.chaotic.nixosModules.default];
  };

  home-manager = {
    imports = [inputs.chaotic.homeModules.default];
  };
}
