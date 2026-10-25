# mise-jasypt

A [mise](https://mise.jdx.dev/) tool plugin for the archived [Jasypt CLI](https://github.com/rahogata/jasypt).

Important: the upstream Jasypt project is archived, and this plugin is intentionally scoped to the last supported release, Jasypt 1.9.3. It is not intended to track newer upstream releases or versions beyond 1.9.3.

This plugin automatically discovers the supported Jasypt 1.9.3 release, downloads the matching distribution archive, verifies its SHA-256 checksum, and exposes the CLI through `mise`.

## Features

- Installs Jasypt CLI via mise
- Supports the archived upstream Jasypt 1.9.3 release only
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

This plugin intentionally supports only the upstream Jasypt 1.9.3 release.

Because the upstream project has been archived, newer release tags are not supported by this plugin and are intentionally excluded from version discovery.

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

The plugin wraps the upstream Jasypt 1.9.3 distribution and exposes the CLI through `mise` so you can manage the supported version cleanly in the same environment.

## License

MIT
