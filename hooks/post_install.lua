local file = require("file")

local function get_filename(path)
    return path:match("[^/\\]+$")
end

local function list_directory(dir)
    local ok, entries = pcall(file.list, dir)

    if not ok then
        error("[mise-jasypt] Unable to list directory '" .. dir .. "': " .. tostring(entries), 0)
    end

    if type(entries) ~= "table" then
        error("[mise-jasypt] Unexpected result listing directory '" .. dir .. "'", 0)
    end

    return entries
end

local function rename_scripts(bin_dir)
    for _, path in ipairs(list_directory(bin_dir)) do
        local name = get_filename(path)

        if name and (name:match("%.bat$") or name:match("%.sh$")) and not name:match("^jasypt_") then
            local new_path = file.join_path(bin_dir, "jasypt_" .. name)

            local exists_ok, destination_exists = pcall(file.exists, new_path)
            if not exists_ok then
                error(
                    "[mise-jasypt] Unable to check destination '" .. new_path .. "': " .. tostring(destination_exists),
                    0
                )
            end

            if destination_exists then
                error(
                    "[mise-jasypt] Cannot rename '" .. path .. "': destination already exists: '" .. new_path .. "'",
                    0
                )
            end

            local move_ok, move_err = pcall(file.move, path, new_path)
            if not move_ok then
                error(
                    "[mise-jasypt] Unable to rename '" .. path .. "' to '" .. new_path .. "': " .. tostring(move_err),
                    0
                )
            end
        end
    end
end

local function make_scripts_executable(bin_dir)
    if RUNTIME.osType == "windows" then
        return
    end

    for _, path in ipairs(list_directory(bin_dir)) do
        local name = get_filename(path)

        if name and name:match("^jasypt_.*%.sh$") then
            local quoted_path = "'" .. path:gsub("'", "'\\''") .. "'"
            local ok, reason, code = os.execute("chmod u+x " .. quoted_path)

            if ok ~= true and ok ~= 0 then
                error(
                    "[mise-jasypt] Unable to make script executable: '"
                        .. path
                        .. "' (reason="
                        .. tostring(reason)
                        .. ", exit_code="
                        .. tostring(code)
                        .. ")",
                    0
                )
            end
        end
    end
end

function PLUGIN:PostInstall(ctx)
    local bin_dir = file.join_path(ctx.rootPath, "bin")

    local stat_ok, stat = pcall(file.stat, bin_dir)
    if not stat_ok then
        error("[mise-jasypt] Unable to inspect script directory '" .. bin_dir .. "': " .. tostring(stat), 0)
    end

    if not stat then
        error("[mise-jasypt] Script directory does not exist: '" .. bin_dir .. "'", 0)
    end

    local ok, err = pcall(function()
        rename_scripts(bin_dir)
        make_scripts_executable(bin_dir)
    end)

    if not ok then
        error(tostring(err), 0)
    end
end
