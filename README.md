# mise-jasypt

A [mise](https://mise.jdx.dev/) tool plugin for the [Jasypt CLI](https://github.com/rahogata/jasypt).

This plugin automatically discovers published Jasypt release versions from the upstream GitHub releases, downloads the matching distribution archive, verifies its SHA-256 checksum, and exposes the `jasypt` command through mise.

## Features

- Installs Jasypt CLI via mise
- Discovers upstream release versions from `rahogata/jasypt`
- Validates release asset checksums
- Exposes a `jasypt` wrapper with commonly used commands
- Works across supported platforms through the upstream distribution archive

## Installation

Install the plugin:

```bash
mise plugin install jasypt https://github.com/rahogata/mise-jasypt.git
```

Then install a version:

```bash
mise install jasypt@latest
```

Or set it in a project or globally:

```bash
mise use -g jasypt@latest
# or
mise use jasypt@latest
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

Versions are discovered from the upstream `rahogata/jasypt` GitHub releases using tag names like:

```text
jasypt-1.9.3
jasypt-2.0.0
```

The plugin matches those tags and maps them to mise versions like:

```text
1.9.3
2.0.0
```

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

The plugin wraps the upstream Jasypt distribution and exposes the CLI through `mise` so you can manage multiple versions cleanly in the same environment.

## License

MIT
