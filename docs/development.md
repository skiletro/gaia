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

Run these recipes from the repository root. Recipes that format or stage run
`git add .`, staging changes under the current directory, including unrelated
work. Formatting recipes stage once before formatting and again afterward.
Review the working tree before running them and the staged changes before
committing. Even `just build`, `just iso`, and `just repl` modify the index;
they are not read-only checks. The system recipes select the local host unless
otherwise noted.

To build without formatting or staging, select a configuration directly:

```sh
nixos-rebuild build --flake .#keres
```

Building Keres requires an AArch64 Linux builder or suitable emulation.

## Other commands

| command | what it does |
|---|---|
| `just update` | updates flake inputs and package sources |
| `just update-inputs [input ...]` | updates all flake inputs, or only the named inputs |
| `just update-sources` | regenerates package sources with nvfetcher |
| `just repl` | formats and stages the working tree, then opens the local system configuration in a REPL |
| `just clean` | removes old store paths and generations with `nh clean all -K 1d`, then optimises the store |
| `just optimise` | optimises the store |
| `just repair` | verifies and repairs the store |
| `just secret` | edits the encrypted secrets file |
| `just secret-rotate` | rotates the SOPS data key and rewrites the encrypted file |
| `just secret-update` | rewrites the file's recipients to match `.sops.yaml` |

Garbage collection can remove rollback generations; review what you need to
retain before running `just clean`. `just repair` can modify store contents.

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

Secrets live in `.secrets.yaml`, encrypted for the age recipients selected by
`.sops.yaml`. All three secret recipes derive `SOPS_AGE_KEY` from
`$HOME/.ssh/id_ed25519`; that private key must already decrypt the file.
`just secret` opens it in SOPS for editing. `just secret-rotate` rotates the
file's data-encryption key, not the SSH keys or age identities.

For a new host, provision its private key securely at
`/home/jamie/.ssh/id_ed25519`, the path used by
[sops-nix](../core/infra/secrets.nix). Derive its public age recipient:

```sh
ssh-to-age < ~/.ssh/id_ed25519.pub
```

Run that command with the new host's public key, not the deploying machine's
key. Add the recipient to the matching creation rule in `.sops.yaml`, then run
`just secret-update` from a machine whose key already decrypts the file. This
updates recipients in place without prompting; review and commit both files.
Host labels in `.sops.yaml` do not discover or provision keys. Keep private keys
out of Git and arrange for the configured key to exist before secret consumers
start; authorizing a public key for SSH login does not provide a decryption key.

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

The target must be reachable over SSH using an authorized key, and `jamie` must
have sudo access. Password and keyboard-interactive SSH logins are disabled on
all hosts, including the installer ISO. The sudo password prompt above is
unaffected.
`--target-host` does not select the flake configuration; keep `.#keres` explicit.
The `just deploy` recipe currently omits that selector, so use the command above
for cross-host deployment.

The command builds on Keres, so the deploying machine does not need to build
AArch64 packages locally. It switches the running system and updates the boot
default; it does not format or stage the working tree. New files must be known
to Git for a Git-backed flake to include them.

## Installer image

`just iso` builds the x86_64 `iso` configuration; it does not install a machine.
To avoid its formatting and staging steps, use:

```sh
nixos-rebuild build-image --flake .#iso --image-variant iso
```

The image includes `disko-install`. Before using it, review the target host's
disk configuration and confirm the actual target devices: installation can
repartition disks and destroy existing data. The image has the same key-only
SSH access described above, so arrange an authorized key before relying on
remote access.
