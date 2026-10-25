local release = require("release")

function PLUGIN:PreInstall(ctx)
    return release.get_install_info(ctx.version)
end
