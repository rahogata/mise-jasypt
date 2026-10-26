local file = require("file")

function PLUGIN:EnvKeys(ctx)
    return {
        { key = "JASYPT_HOME", value = ctx.path },
        { key = "JASYPT_VERSION", value = ctx.version },
        { key = "PATH", value = file.join_path(ctx.path, "bin") },
    }
end
