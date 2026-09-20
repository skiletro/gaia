# Development

## Prerequisites

A nix installation with flakes enabled, and direnv (the repo uses `use flake`).
Entering the repo drops you into the devShell, which provides `git`, `lazygit`,
`neovim`, `nh`, `nixos-rebuild`, `nvfetcher`, `sops` and `ssh-to-age`.

## Commands

Everything goes through `just`. Run `just` for the full list with descriptions.

| command | what it does |
|---|---|
| `just switch` | format, stage, then build and switch the generation |
| `just boot` | format, stage, then build and update the bootloader |
| `just build` | format, stage, then build |
| `just test` | build and test the generation |
| `just deploy <host>` | build and deploy to a remote host over ssh |
| `just pkg <name>` | build a package from this flake |
| `just iso` | build the installer ISO |
| `just update` | update flake inputs and package sources |
| `just update-inputs [input]` | update flake inputs |
| `just update-sources` | regenerate package sources with nvfetcher |
| `just repl` | open a repl with the flake imported |
| `just clean` | garbage collect and optimise the store |
| `just optimise` | optimise the store |
| `just repair` | verify and repair the store |
| `just secret` | edit the encrypted secrets file |
| `just secret-rotate` | rotate secret keys |
| `just secret-update` | update keys against the hosts in `.sops.yaml` |

## Formatting

`nix fmt` runs treefmt, which covers alejandra, deadnix, keep-sorted,
nixf-diagnose, statix and toml-sort. `nix flake check` includes a formatting
check, so keep the tree formatted before opening a pull request.

## Updating

- `just update-inputs` refreshes the flake inputs in `flake.lock`.
- `just update-sources` re-runs nvfetcher after editing `packages/nvfetcher.toml`.
  The generated files in `packages/_sources/` are committed.

## Secrets

Secrets live in `.secrets.yaml`, encrypted for the age keys in `.sops.yaml`.
Edit the file with `just secret`. The age key is derived from the local SSH key
with `ssh-to-age`. New hosts need their age key added to `.sops.yaml`, then
re-encrypt with `just secret-update`.

Bundles read secrets through sops-nix, for example:

```nix
sops.secrets."wakapi-key" = {};
```

and then use the path:

```nix
config.sops.secrets.wakapi-key.path
```

## Deployment

`just deploy <host>` builds on the target and switches, connecting as
`jamie@<host>`. The host must be reachable over ssh and the user must have sudo.
