{
  nixos.services = {
    speechd.enable = false;
    dbus.implementation = "broker";
  };
}
