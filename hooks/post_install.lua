local file = require("file")

local function prefix_scripts(bin_dir)
    for _, path in ipairs(file.list(bin_dir)) do
        local stat = file.stat(path)

        if stat and stat.is_file then
            local name = path:match("[^/\\]+$")

            if name and (name:match("%.bat$") or name:match("%.sh$")) and not name:match("^jasypt_") then
                local new_path = file.join_path(bin_dir, "jasypt_" .. name)

                if file.exists(new_path) then
                    error("Cannot rename " .. path .. ": destination already exists: " .. new_path)
                end

                file.move(path, new_path)
            end
        end
    end

    if RUNTIME.osType ~= "windows" then
        for _, path in ipairs(file.list(bin_dir)) do
            local name = path:match("[^/\\]+$")

            if name and name:match("^jasypt_.*%.sh$") then
                local ok, err, code = os.execute("chmod u+x '" .. path:gsub("'", "'\\''") .. "'")

                if ok ~= true and ok ~= 0 then
                    error(
                        "Unable to make script executable: "
                            .. path
                            .. " ("
                            .. tostring(err)
                            .. ", exit code "
                            .. tostring(code)
                            .. ")"
                    )
                end
            end
        end
    end
end

function PLUGIN:PostInstall(ctx)
    prefix_scripts(file.join_path(ctx.rootPath, "bin"))
end
