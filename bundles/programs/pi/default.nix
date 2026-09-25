{
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
