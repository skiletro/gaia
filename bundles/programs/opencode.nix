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
        model = "opencode-go/gpt-5.6-luna";
        autoupdate = false;
        lsp = true;

        compaction.prune = true;

        permission.external_directory = {
          "*" = "ask";
          "/home/jamie/.local/share/rtk" = "allow";
          "/home/jamie/.local/share/rtk/**" = "allow";
        };

        mcp = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };

          github = {
            type = "remote";
            url = "https://api.githubcopilot.com/mcp/";
            oauth = {};
          };
        };

        provider."opencode-go".options.apiKey = "{file:${config.sops.secrets.opencode-api-key.path}}";

        plugin = [
          # keep-sorted start
          "@tarquinen/opencode-dcp@3.1.14"
          "opencode-notificator@git+https://github.com/panta82/opencode-notificator.git"
          "opencode-rtk"
          "opencode-vibeguard@0.1.0"
          "opencode-wakatime@1.3.9"
          "superpowers@git+https://github.com/obra/superpowers.git"
          # keep-sorted end
        ];
      };

      skills = {
        caveman = "${inputs.caveman}/skills/caveman";
        gitingest = ''
          ---
          name: gitingest
          description: Use when you need to understand a repository that isn't already in context
            — analyse a foreign codebase, summarise a repo, inspect dependencies, or gather
            code context for review. Turns any git repo into a prompt-ready text digest.
          ---

          # gitingest

          Turn a git repo into a plain-text digest for LLM consumption. The CLI is
          installed via `pkgs.gitingest` (nixpkgs), so `gitingest` is on PATH wherever
          opencode is enabled.

          ## When to use

          - A repo (or its relevant parts) is unknown and not yet read into context
          - Summarising a whole repository before working in it
          - Dependency / security analysis across many files
          - Gathering a codebase as context for review

          Skip when the relevant files are already small and read into context.

          ## Usage

          Basic digest to stdout:

              gitingest https://github.com/user/repo -o -

          Focus and filter (globs, size cap, branch):

              gitingest <repo> -i "*.py" -e "node_modules/*" -s 51200 -b main -o -

          Private repos: export GITHUB_TOKEN. See `gitingest --help` for all flags.

          ## Output shape

          Three sections: repo summary + token estimate, directory tree, then each file
          wrapped in `==== FILE: <path> ====` delimiters.

          Use the `-o -` stdout stream when the digest is large, and prefer
          include/exclude patterns over ingesting whole monorepos.
        '';
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

    home.packages = [pkgs.gitingest pkgs.rtk];

    sops.secrets."opencode-api-key" = {};
  };
}
