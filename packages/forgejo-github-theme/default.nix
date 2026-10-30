{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  bun,
  ...
}:
buildNpmPackage {
  pname = "forgejo-github-theme";
  version = "0-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "skiletro";
    repo = "forgejo-github-theme";
    rev = "71685fb3b82092d3a3e928240883a7d4f88f02fa";
    hash = "sha256-jFqszrQUSecVYouc1CqEXsqTOuO9krAcnuKhlwVLPAI=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-D8PQUuGl+QJuxLmWrbbdKGLGTjJwKtDSMcCoFZ/Ca/g=";
  # Upstream uses Bun; its unused ESLint tooling has peers that exclude TypeScript 7.
  npmFlags = ["--legacy-peer-deps"];
  nativeBuildInputs = [bun];
  buildPhase = ''
    runHook preBuild
    # Invoke Bun directly: Nix's patched executable shebangs otherwise select Node.
    bun node_modules/typescript/bin/tsc -b
    bun node_modules/vite/bin/vite.js build
    bun scripts/assembleForgejo.ts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist/forgejo "$out"
    runHook postInstall
  '';

  meta = {
    description = "Forgejo GitHub layouts with the warm.vodka dark theme";
    homepage = "https://github.com/skiletro/forgejo-github-theme";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
