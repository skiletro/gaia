{
  nixos = {
    networking.networkmanager.enable = true;

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users.jamie.extraGroups = [ "networkmanager" ];
  };
}
