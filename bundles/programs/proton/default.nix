{
  home-manager = {pkgs, ...}: {
    home.packages = with pkgs; [
      proton-pass-cli
      proton-vpn-cli
    ];
  };
}
