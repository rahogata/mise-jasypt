-- hooks/post_install.lua
local file = require("file")
local cmd = require("cmd")

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

function PLUGIN:PostInstall(ctx)
    -- Locate this plugin's root directory from this hook's source file.
    local source = debug.getinfo(1, "S").source
    local hook_path = source:sub(1, 1) == "@" and source:sub(2) or nil

    if not hook_path then
        error("Unable to determine plugin source directory")
    end

    local plugin_root = hook_path:match("^(.*)/hooks/[^/]+$")
    if not plugin_root then
        error("Unable to determine plugin root from: " .. hook_path)
    end

    local wrapper_source = file.join_path(plugin_root, "scripts", "jasypt")
    local wrapper_dir = file.join_path(ctx.rootPath, "mise-bin")
    local wrapper_dest = file.join_path(wrapper_dir, "jasypt")

    if not file.exists(wrapper_source) then
        error("Wrapper script not found: " .. wrapper_source)
    end

    cmd.exec("mkdir -p " .. shell_quote(wrapper_dir))
    cmd.exec("cp " .. shell_quote(wrapper_source) .. " " .. shell_quote(wrapper_dest))
    cmd.exec("chmod u+x " .. shell_quote(wrapper_dest))
end
