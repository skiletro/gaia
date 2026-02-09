{
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  config = {
    sops = {
      inherit (osConfig.sops) defaultSopsFile age;
    };
  };
}
