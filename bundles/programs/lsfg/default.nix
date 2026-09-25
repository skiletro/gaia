{
  nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      lsfg-vk
      lsfg-vk-ui
    ];
  };
}
