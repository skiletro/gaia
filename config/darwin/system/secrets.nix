{ self, inputs, ... }:
{
  imports = [ inputs.sops-nix.darwinModules.default ];

  sops = {
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    age.sshKeyPaths = [
      "/Users/jamie/.ssh/id_ed25519"
    ];
  };
}
