# mise-jasypt

A [mise](https://mise.jdx.dev/) tool plugin for the [Jasypt CLI](https://github.com/rahogata/jasypt).

This project packages the Jasypt CLI from the maintained fork at `rahogata/jasypt`, which is the source used for the plugin’s published artifacts and version metadata. The plugin is intentionally scoped to the Jasypt 1.9.3 release line and does not aim to track newer upstream or forked versions.

This plugin automatically discovers the supported Jasypt 1.9.3 release from the forked upstream releases, downloads the matching distribution archive, verifies its SHA-256 checksum, and exposes the CLI through `mise`.

## Features

- Installs Jasypt CLI via mise
- Discovers versions from the `rahogata/jasypt` fork
- Supports the Jasypt 1.9.3 release line only
- Validates the release asset checksum
- Exposes a `jasypt` wrapper with commonly used commands
- Works across supported platforms through the upstream distribution archive

## Installation

Install the plugin:

```bash
mise plugin install jasypt https://github.com/rahogata/mise-jasypt.git
```

Then install the supported version:

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
jasypt encrypt input="hello"
jasypt decrypt input="ENC(...)"
jasypt digest input="hello"
jasypt list-algorithms
```

## Available versions

This plugin intentionally supports only the Jasypt 1.9.3 release published from the `rahogata/jasypt` fork.

Version discovery is limited to the artifacts published by that fork, and newer release tags are not included in the plugin’s supported set.

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

The plugin wraps the Jasypt 1.9.3 distribution published from the `rahogata/jasypt` fork and exposes the CLI through `mise` so you can manage the supported version cleanly in the same environment.

## License

MIT
