# mise-jasypt

A [mise](https://mise.jdx.dev/) tool plugin for the [Jasypt CLI](https://github.com/rahogata/jasypt).

This project packages the Jasypt CLI from the maintained fork at `rahogata/jasypt`, which is the source used for the plugin's published artifacts and version metadata. The plugin discovers stable release tags from that fork, finds the matching distribution archive, verifies its checksum, and installs a wrapper so the CLI can be used via `mise`.

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
mise plugins install jasypt https://github.com/rahogata/mise-jasypt.git
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

## Plugin compatibility

This plugin is intended for current stable `mise` releases and the platforms for which the upstream Jasypt distribution archive is published.

- Supported platforms: Linux x86_64, Linux arm64, macOS x86_64, macOS arm64, Windows x86_64
- Supported mise versions: current stable release line only; older versions are not officially supported or tested
- Windows support is officially supported and validated in CI (`windows-latest`)
- External programs used: Java runtime required to execute the Jasypt CLI; on Windows, install a JRE or JDK that is available on `PATH` so the generated `.bat` wrapper can launch the bundled Jasypt jar.

## Usage

After installation, use the Jasypt CLI as normal. The plugin exposes the standard Jasypt commands, including:

```bash
jasypt --help
jasypt --version
jasypt encrypt input="hello" password="secret"
jasypt decrypt input="<raw-ciphertext-from-encrypt-output>" password="secret"
jasypt digest input="hello"
jasypt list-algorithms
```

Commonly used commands:

- `jasypt --help` — show the available Jasypt CLI commands and options
- `jasypt --version` — print the installed version
- `jasypt encrypt` — encrypt a value with a password
- `jasypt decrypt` — decrypt a raw ciphertext produced by `encrypt`
- `jasypt digest` — generate a digest/hash of a value
- `jasypt list-algorithms` — list the supported encryption algorithms

Example workflow:

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

The `decrypt` command expects the raw ciphertext value produced by `encrypt`, not a wrapped `ENC(...)` string. In other words, the value passed to `input=` should be the exact output from the encrypt command.

## Available versions

This plugin discovers the stable Jasypt release tags published by the `rahogata/jasypt` fork. Available versions are whatever published `jasypt-*` tags are present in that repository, so the plugin can install any stable release that matches the upstream distribution format.

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
