{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "pi"] {
  home-manager = {pkgs, ...}: {
    programs.pi-coding-agent = {
      enable = true;
      extraPackages = with pkgs; [
        nodejs
        bun
        rtk
      ];
    };
  };
}
