{lib, ...}: {
  options.gaia.device.type = lib.mkOption {
    type = lib.types.enum ["desktop" "laptop" "server" "vm" "installer"];
    default = "desktop";
    description = "Host role label; does not enable hardware modules or power policy.";
  };
}
