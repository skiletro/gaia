{
  gaia = {
    desktop = "mango";
    system = {
      # keep-sorted start
      autologin.enable = true;
      bluetooth.enable = true;
      emulation.enable = true;
      fonts.enable = true;
      greeter.enable = true;
      # keep-sorted end
    };
    services = {
      # keep-sorted start
      flatpak.enable = true;
      printing.enable = true;
      wireguard.enable = true;
      # keep-sorted end
    };
    programs = {
      # keep-sorted start
      btop.enable = true;
      devenv.enable = true;
      direnv.enable = true;
      discord.enable = true;
      git.enable = true;
      helium.enable = true;
      helix.enable = true;
      nu.enable = true;
      pi.enable = true;
      proton.enable = true;
      pwa.enable = true;
      qbittorrent.enable = true;
      signal.enable = true;
      spotatui.enable = true;
      term-utils.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
      # keep-sorted end
    };
    state.system = "26.11";
  };
}
