{
  lib,
  config,
  ...
}: let
  # Autologin bypasses the session chooser, so the enabled desktop must be unique.
  enabledDesktops = lib.filter (name: config.gaia.desktops.${name}.enable) (lib.attrNames config.gaia.desktops);
  desktop =
    if builtins.length enabledDesktops == 1
    then builtins.head enabledDesktops
    else throw "gaia.system.autologin.enable requires exactly one enabled gaia.desktops.<name>.enable";
in {
  nixos = {
    config,
    pkgs,
    ...
  }: {
    services.greetd.settings.initial_session = {
      command = "${lib.getExe config.programs.uwsm.package} start -- ${desktop}-uwsm.desktop";
      user = "jamie";
    };

    systemd.services.greetd.serviceConfig = {
      KeyringMode = lib.mkForce "inherit";
    };

    security.pam.services.login.rules.session.fde-boot-pw = {
      control = "optional";
      modulePath = "${pkgs.pam_fde_boot_pw}/lib/security/pam_fde_boot_pw.so";
      settings.inject_for = "gkr";
      order = config.security.pam.services.login.rules.session.gnome_keyring.order - 100;
    };
  };
}
