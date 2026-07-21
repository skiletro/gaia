{ bundleLib, lib, ... }:
bundleLib.mkEnableModule [ "gaia" "system" "autologin" ] {

  nixos =
    { pkgs, ... }:
    {

      services.greetd.settings.initial_session = {
        command = "uwsm start -- niri-uwsm.desktop";
        user = "jamie";
      };

      systemd.services.greetd.serviceConfig = {
        KeyringMode = lib.mkForce "inherit";
        Type = lib.mkForce "idle";
      };

      security.pam.services.greetd.rules.session.fde-boot-pw = {
        control = "optional";
        modulePath = "${pkgs.pam_fde_boot_pw}/lib/security/pam_fde_boot_pw.so";
        settings.inject_for = "gkr";
        order = 12500;
      };

    };

}
