-- metadata.lua
-- Plugin metadata and configuration
-- Documentation: https://mise.jdx.dev/tool-plugin-development.html#metadata-lua

PLUGIN = { -- luacheck: ignore
    -- Required: Plugin metadata name
    name = "jasypt",

    -- Required: Plugin metadata version
    version = "1.0.0",

    -- Optional: Plugin description
    description = "A mise tool plugin for jasypt",

    -- Optional: Plugin author
    author = "rahogata",

    -- Optional: License name
    license = "MIT",

    -- Optional: Plugin homepage
    homepage = "https://github.com/rahogata/mise-jasypt",

    -- Optional: Legacy version files this plugin can parse
    -- legacyFilenames = {
    --     ".<TOOL>-version",
    --     ".<TOOL>rc"
    -- },

    -- Optional: configured mise tools to add to install-hook PATH
    -- depends = { "node" },
}
