{ self, inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.default ];

  sops = {
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    age.sshKeyPaths = [
      "/home/jamie/.ssh/id_ed25519"
    ];
  };
}
