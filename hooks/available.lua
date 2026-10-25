local release = require("release")

function PLUGIN:Available(ctx)
    return release.list()
end
