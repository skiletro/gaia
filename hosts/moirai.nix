{
  gaia = {
    desktop = "aerospace";
    system = {
      # keep-sorted start
      bluetooth.enable = true;
      fonts.enable = true;
      virtualisation.enable = true;
      # keep-sorted end
    };
    services = {
      # keep-sorted start
      # flatpak.enable = true;
      # kdeconnect.enable = true; # TODO: add kde support to module
      # printing.enable = true;
      # wireguard.enable = true;
      # keep-sorted end
    };
    programs = {
      # keep-sorted start
      # beets.enable = true;
      broot.enable = true;
      btop.enable = true;
      direnv.enable = true;
      discord.enable = true;
      # gamemode.enable = true;
      git.enable = true;
      # gsr.enable = true;
      helium.enable = true;
      helix.enable = true;
      khal.enable = true;
      kitty.enable = true;
      libreoffice.enable = true;
      # lsfg.enable = true;
      nu.enable = true;
      proton.enable = true;
      qbittorrent.enable = true;
      rustdesk.enable = true;
      signal.enable = true;
      spotify.enable = true;
      # steam.enable = true;
      term-utils.enable = true;
      # wivrn.enable = true;
      zed.enable = true;
      # keep-sorted end
    };
    state = {
      system = 6;
      home = "25.11";
    };
  };
}
