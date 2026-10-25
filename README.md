# mise-jasypt

A [mise](https://mise.jdx.dev/) tool plugin for the [Jasypt CLI](https://github.com/rahogata/jasypt).

This project packages the Jasypt CLI from the maintained fork at `rahogata/jasypt`, which is the source used for the plugin's published artifacts and version metadata. The plugin discovers stable release tags from that fork, downloads the matching distribution archive, verifies its SHA-256 checksum, and exposes the CLI through `mise`.

## Features

- Installs Jasypt CLI via mise
- Discovers versions from the `rahogata/jasypt` fork
- Supports published stable Jasypt release tags from that fork
- Validates the release asset checksum
- Exposes a `jasypt` wrapper with commonly used commands
- Works across supported platforms through the upstream distribution archive

## Installation

Install the plugin:

```bash
mise plugin install jasypt https://github.com/rahogata/mise-jasypt.git
```

Then install a published version, for example:

```bash
mise install jasypt@1.9.3
```

Or set it in a project or globally:

```bash
mise use -g jasypt@1.9.3
# or
mise use jasypt@1.9.3
```

## Usage

After installation, use the Jasypt CLI as normal:

```bash
jasypt --help
jasypt --version

# Encrypt a value with a password and capture the raw ciphertext emitted by Jasypt.
jasypt encrypt input="hello" password="secret"

# Decrypt the raw ciphertext returned by the previous command.
jasypt decrypt input="<raw-ciphertext-from-encrypt-output>" password="secret"

jasypt digest input="hello"
jasypt list-algorithms
```

The `decrypt` command expects the raw ciphertext value produced by `encrypt`, not a wrapped `ENC(...)` string. In other words, the value passed to `input=` should be the exact output from the `encrypt` command's `----OUTPUT` section.

## Available versions

This plugin discovers the stable Jasypt release tags published by the `rahogata/jasypt` fork. Available versions are whatever published `jasypt-*` tags are present in that repository, so the plugin follows the released stable versions instead of restricting itself to a single version.

## Development

This plugin follows the standard mise Lua plugin structure with:

- `metadata.lua` for plugin metadata
- `hooks/available.lua` for version discovery
- `hooks/pre_install.lua` for download metadata and checksum verification
- `hooks/post_install.lua` for wrapper setup
- `hooks/env_keys.lua` for environment variables

Common development tasks:

```bash
mise install
mise run lint
mise run test
mise run ci
```

## Notes

The plugin wraps the Jasypt distribution published from the `rahogata/jasypt` fork and exposes the CLI through `mise` so you can manage published stable versions cleanly in the same environment.

## License

MIT
