{
  nixos.system = {
    disableInstallerTools = true;
    tools.nixos-rebuild.enable = true;
  };
}
