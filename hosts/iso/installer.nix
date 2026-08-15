{inputs', ...}: {
  nixos = {modulesPath, ...}: {
    system.switch.enable = false;

    imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")];

    environment.systemPackages = [inputs'.disko.packages.disko-install];
  };
}
