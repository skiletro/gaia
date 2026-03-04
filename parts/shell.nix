{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [
          # keep-sorted start ignore_prefixes=self'.packages.
          git
          lazygit
          neovim
          nh
          nixos-rebuild
          nvfetcher
          sops
          ssh-to-age
          # keep-sorted end
        ];

        JUST_LIST_HEADING = "";
        JUST_LIST_PREFIX = "";

        shellHook = ''
          echo
          just
          echo
          git status -sb
          echo
        '';
      };
    };
}
