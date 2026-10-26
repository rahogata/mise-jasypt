local http = require("http")
local json = require("json")

local function fetch_release_versions()
    local versions = {}
    local page = 1

    while true do
        local url = "https://api.github.com/repos/rahogata/jasypt/releases?per_page=100&page=" .. page
        local response, err = http.get(url, {
            headers = {
                ["Accept"] = "application/vnd.github+json",
                ["User-Agent"] = "mise-jasypt",
            },
        })

        if err or not response then
            return versions
        end

        if response.status_code ~= 200 then
            return versions
        end

        local releases = json.decode(response.body)
        if type(releases) ~= "table" or #releases == 0 then
            break
        end

        for _, release in ipairs(releases) do
            if type(release) == "table" and release.tag_name then
                table.insert(versions, release.tag_name)
            end
        end

        if #releases < 100 then
            break
        end

        page = page + 1
    end

    return versions
end

function PLUGIN:Available(ctx)
    return fetch_release_versions()
end
