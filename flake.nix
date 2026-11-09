{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./parts);

  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    appimage-appmanager = {
      url = "github:kem-a/AppManager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    artcraft = {
      url = "github:Devitek/artcraft-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    asahix.url = "github:warm-vodka/asahix";

    bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bundlix.url = "github:warm-vodka/bundlix";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    chromium-webapps = {
      url = "github:warm-vodka/nix-chromium-webapps";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    cursors.url = "github:lilleaila/nix-cursors";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    helium = {
      url = "github:warm-vodka/heliumix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    mango = {
      url = "github:mangowm/mango";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        scenefx.follows = "scenefx";
      };
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        nix-darwin.follows = "";
        treefmt-nix.follows = "";
      };
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs = {
        treefmt-nix.follows = "treefmt-nix";
        flake-compat.follows = "";
      };
    };

    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    scenefx = {
      url = "github:wlrfx/scenefx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sonora = {
      url = "github:sonorahq/sonora";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.flake-parts.follows = "flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuigreet = {
      url = "github:tuigreet/tuigreet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    warm-vodka-forgejo-theme = {
      url = "github:warm-vodka/forgejo-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    warm-vodka-landing-page = {
      url = "github:warm-vodka/landing";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  nixConfig = {
    extra-trusted-substituters = [
      # keep-sorted start
      "https://asahix.cachix.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
      "https://nyx-cache.chaotic.cx/"
      # keep-sorted end
    ];
    extra-trusted-public-keys = [
      # keep-sorted start
      "asahix.cachix.org-1:SDzLl9HW7kV2h/6yBCZwjhveL2HUjjdI0x+qFB0I54Y="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      # keep-sorted end
    ];
  };
}
