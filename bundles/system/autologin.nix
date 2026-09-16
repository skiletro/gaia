{
  bundleLib,
  lib,
  config,
  ...
}: let
  desktop = config.gaia.desktop;
in
  bundleLib.mkEnableModule ["gaia" "system" "autologin"] {
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
