{inputs, ...}: {
  home-manager = {
    imports = [inputs.omp.homeManagerModules.default];

    programs.omp.enable = true;
  };
}
