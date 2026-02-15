{ inputs, self, ... }:
let
  defaultSopsFile = "${self}/.secrets.yaml";
in
{
  nixos = {
    imports = [ inputs.sops-nix.nixosModules.default ];

    sops = {
      inherit defaultSopsFile;
      age.sshKeyPaths = [
        "/home/jamie/.ssh/id_ed25519"
      ];
    };
  };

  home-manager =
    { osConfig, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        inherit (osConfig.sops) defaultSopsFile age;
      };
    };

  darwin = {
    imports = [ inputs.sops-nix.darwinModules.default ];

    sops = {
      inherit defaultSopsFile;
      age.sshKeyPaths = [
        "/Users/jamie/.ssh/id_ed25519"
      ];
    };
  };
}
