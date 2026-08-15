{
  inputs,
  self,
  ...
}: {
  flake.deploy.nodes.keres = {
    hostname = "keres";
    sshUser = "jamie";
    interactiveSudo = true;

    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.keres;
    };
  };
}
