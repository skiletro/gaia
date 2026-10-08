{lib, ...}: {
  options.gaia.device.type = lib.mkOption {
    type = lib.types.enum ["desktop" "laptop" "server" "vm" "installer"];
    default = "desktop";
    description = "Host role used to choose defaults for device-aware policy; does not select hardware modules.";
  };
}
