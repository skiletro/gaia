{ lib, ... }:
{
  home-manager =
    { pkgs, ... }:
    {
      programs.btop = {
        enable = true;
        package = with pkgs.hostPlatform; lib.mkIf (isLinux && isx86_64) pkgs.btop-rocm;
        settings = {
          update_ms = 200;
          show_boxes = "proc cpu mem net gpu gpu0 gpu1 gpu2";
        };
      };
    };
}
