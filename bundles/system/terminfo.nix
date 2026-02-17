{
  nixos =
    { pkgs, ... }:
    {
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
