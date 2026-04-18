{
  gaia = {
    desktop = "rectangle";
    system = {
      # keep-sorted start
      bluetooth.enable = true;
      emulation.enable = true;
      fonts.enable = true;
      virtualisation.enable = true;
      # keep-sorted end
    };
    programs = {
      # keep-sorted start
      broot.enable = true;
      btop.enable = true;
      direnv.enable = true;
      discord.enable = true;
      git.enable = true;
      helium.enable = true;
      helix.enable = true;
      kitty.enable = true;
      libreoffice.enable = true;
      nu.enable = true;
      proton.enable = true;
      qbittorrent.enable = true;
      rustdesk.enable = true;
      signal.enable = true;
      spotify.enable = true;
      term-utils.enable = true;
      # keep-sorted end
    };
    state = {
      system = 6;
      home = "25.11";
    };
  };
}
