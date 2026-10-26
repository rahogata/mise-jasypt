local file = require("file")

function PLUGIN:EnvKeys(ctx)
    local bin = RUNTIME.osType == "windows" and ctx.path or file.join_path(ctx.path, "bin")

    return {
        { key = "JASYPT_HOME", value = ctx.path },
        { key = "JASYPT_VERSION", value = ctx.version },
        { key = "PATH", value = bin },
    }
end
