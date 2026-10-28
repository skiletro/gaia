# Development

## Getting started

Install Nix with flakes enabled and `just`. Enter the development shell with
`nix develop`, or use `direnv allow` if you have direnv installed. The shell
provides `nh`, `nixos-rebuild`, `nvfetcher`, `sops`, and `ssh-to-age`.

Run `just` to see available recipes.

## Build and deploy

| command | effect |
|---|---|
| `just build` | formats and stages the entire working tree, then builds the local system |
| `just switch` | formats and stages the entire working tree, then builds and switches the local system |
| `just test` | formats and stages the entire working tree, then activates the local system without making it the boot default |
| `just boot` | formats and stages the entire working tree, then builds and sets the next boot generation |
| `just iso` | formats and stages the entire working tree, then builds the installer image |
| `just pkg <name>` | builds one flake package |

The `just` recipes that format or stage run `git add .`; this stages all
repository changes, including unrelated work. Review the staged changes before
committing or deploying. The system recipes act on the local host unless
otherwise noted.

## Other commands

| command | what it does |
|---|---|
| `just update` | updates flake inputs and package sources |
| `just update-inputs [input]` | updates flake inputs, optionally only one |
| `just update-sources` | regenerates package sources with nvfetcher |
| `just repl` | formats and stages the working tree, then opens the local system configuration in a REPL |
| `just clean` | garbage collects and optimises the store |
| `just optimise` | optimises the store |
| `just repair` | verifies and repairs the store |
| `just secret` | edits the encrypted secrets file |
| `just secret-rotate` | rotates secret keys |
| `just secret-update` | updates keys against hosts in `.sops.yaml` |

## Formatting

`nix fmt` runs treefmt. See [Formatting](conventions.md#formatting) for the
configured tools. `nix flake check` includes a formatting check.

## Updating inputs and packages

- `just update-inputs` updates `flake.lock`.
- `just update-sources` regenerates `packages/_sources/` from
  `packages/nvfetcher.toml`. Commit the generated files with the source
  declaration changes.

See [Package examples](package-examples.md) to add a package.

## Secrets

Secrets live in `.secrets.yaml`, encrypted for the age keys in `.sops.yaml`.
`just secret` opens the file for editing. The age key is derived from the local
SSH key with `ssh-to-age`. When adding a host, add its age key to `.sops.yaml`,
then re-encrypt the secrets with `just secret-update`.

Bundles read secrets through sops-nix:

```nix
sops.secrets."tailscale-auth-key" = {};
```

Use the secret path from module configuration:

```nix
config.sops.secrets."tailscale-auth-key".path
```

See [Tailscale](../bundles/services/tailscale/default.nix) for a complete example.

## Remote deployment

Select the configuration explicitly when deploying to another machine. For Keres:

```sh
nixos-rebuild switch --flake .#keres \
  --target-host jamie@keres \
  --build-host jamie@keres \
  --use-substitutes \
  --no-reexec \
  --sudo --ask-sudo-password
```

The target must be reachable over SSH and `jamie` must have sudo access.
`--target-host` does not select the flake configuration; keep `.#keres` explicit.
The `just deploy` recipe currently omits that selector, so use the command above
for cross-host deployment.
