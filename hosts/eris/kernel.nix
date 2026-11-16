{
  nixos = {pkgs, ...}: {
    boot.kernelPackages = pkgs.linuxPackages_zen;

    services = {
      scx-loader = {
        enable = true;
        config.default_sched = "scx_lavd";
      };

      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos_git;
      };
    };
  };
}
