{ bundleLib, ... }:
bundleLib.mkEnableModule [ "gaia" "programs" "ollama" ] {

  nixos = { pkgs, ... }: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm.overrideAttrs (
        _:
        let
          version = "0.32.13";
          hash = "sha256-KSvw7LsvpUVeSm9BKJ4wIp/fWGHjMp8bOTMUpFJCDmw=";
        in
        {
          inherit version;
          src = pkgs.fetchFromGitHub {
            owner = "ollama";
            repo = "ollama";
            tag = "v${version}";
            inherit hash;
          };
        }
      );
    };

    environment.systemPackages = [ pkgs.alpaca ];
  };

}
