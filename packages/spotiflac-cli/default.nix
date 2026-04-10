{
  sources,
  buildGoModule,
  ...
}:
buildGoModule {
  inherit (sources.spotiflac-cli) pname version src;
  tags = [ "headless" ];
  vendorHash = "sha256-Gdh1aE3OBAMXlN/eVCABC0MEHta6eXWgAjYEm9K+mU8=";
  meta.mainProgram = "spotiflac";
}
