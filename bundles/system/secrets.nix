{inputs, self, ...}: {
  nixos = {
    imports = [ inputs.sops-nix.nixosModules.default ];

    sops = {
      defaultSopsFile = "${self}/.secrets.yaml";
      age.sshKeyPaths = [
        "/home/jamie/.ssh/id_ed25519"
      ];
    };
  };
}
