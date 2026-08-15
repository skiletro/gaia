{
  bundleLib,
  inputs,
  ...
}:
bundleLib.mkEnableModule ["gaia" "programs" "opencode"] {
  gaia.programs.wakatime.enable = true;

  home-manager = {
    pkgs,
    config,
    ...
  }: {
    programs.opencode = {
      enable = true;
      settings = {
        model = "opencode-go/deepseek-v4-flash";
        autoupdate = false;
        lsp = true;

        compaction.prune = true;

        provider."opencode-go".options.apiKey = "{file:${config.sops.secrets.opencode-api-key.path}}";

        plugin = [
          # keep-sorted start
          "@tarquinen/opencode-dcp@3.1.14"
          "opencode-notificator@git+https://github.com/panta82/opencode-notificator.git"
          "opencode-snip@1.6.1"
          "opencode-vibeguard@0.1.0"
          "opencode-wakatime@1.3.9"
          "superpowers@git+https://github.com/obra/superpowers.git"
          # keep-sorted end
        ];
      };

      skills = {
        caveman = "${inputs.caveman}/skills/caveman";
        nixos = "${inputs.nixos-ai-skill}";
      };

      context = ''
        # Global preferences

        These preferences apply in every project.

        ## Communication

        - Use British English spelling.
        - Be concise and direct. No filler or hedging.
        - Keep replies proportionate to the question.

        ## Code

        - Match the existing style and conventions of the project.
        - Keep diffs minimal. Do not reformat unrelated code.
        - Do not add comments unless asked.
        - Follow the project's own contribution rules when present.

        ## Nix

        - Format with alejandra (`nix fmt`).
        - Keep lists inside keep-sorted blocks sorted.
        - Prefer `lib` idioms and the `callPackage` pattern for packages.
        - Prefer smaller, focused changes over large rewrites.

        ## Commits

        - Use conventional commits with a scope when relevant, e.g. `feat(bundle): ...`, `fix(eris): ...`, `chore: ...`.
        - Keep the subject line short and imperative.
        - Do not commit unless asked.

        ## Safety

        - Ask before destructive or irreversible operations.
        - Never log or print secrets, keys, or tokens.
      '';
    };

    home.packages = [pkgs.snip];

    sops.secrets."opencode-api-key" = {};
  };
}
