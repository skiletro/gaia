{ lib, ... }:
{
  nixos =
    { pkgs, ... }:
    {
      environment.defaultPackages = lib.mkForce [ pkgs.vim ];

      programs.nano.enable = false;

      environment.systemPackages = map (x: pkgs.${x}.terminfo) [
        # keep-sorted start
        "alacritty"
        "foot"
        "ghostty"
        "kitty"
        "wezterm"
        # keep-sorted end
      ];
    };
}
