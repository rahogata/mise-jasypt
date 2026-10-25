local M = {}

M.owner = "rahogata"
M.repo = "jasypt"
M.api_url = "https://api.github.com/repos/" .. M.owner .. "/" .. M.repo

local http = require("http")
local json = require("json")

local function get(url)
    local response = http.get({
        url = url,
        headers = {
            Accept = "application/vnd.github+json",
            ["X-GitHub-Api-Version"] = "2022-11-28",
        },
    })

    if response.status_code ~= 200 then
        error("GitHub API returned HTTP " .. response.status_code .. ": " .. url)
    end

    return response.body
end

function M.list()
    local releases = json.decode(get(M.api_url .. "/releases?per_page=100"))
    local result = {}

    for _, release in ipairs(releases) do
        if not release.draft and not release.prerelease then
            local version = release.tag_name:match("^jasypt%-(.+)$")

            if version then
                table.insert(result, {
                    version = version,
                    created_at = release.published_at,
                })
            end
        end
    end

    return result
end

function M.get_release(version)
    local tag = "jasypt-" .. version
    local release = json.decode(get(M.api_url .. "/releases/tags/" .. tag))

    if release.draft or release.prerelease then
        error("Jasypt release is not a published stable release: " .. tag)
    end

    return release
end

function M.get_install_info(version)
    local release = M.get_release(version)
    local asset_name = "jasypt-" .. version .. "-dist.zip"
    local checksum_name = asset_name .. ".sha256"

    local asset_url
    local checksum_url

    for _, asset in ipairs(release.assets or {}) do
        if asset.name == asset_name then
            asset_url = asset.browser_download_url
        elseif asset.name == checksum_name then
            checksum_url = asset.browser_download_url
        end
    end

    if not asset_url then
        error("Missing release asset: " .. asset_name)
    end

    if not checksum_url then
        error("Missing SHA-256 asset: " .. checksum_name)
    end

    local checksum_body = get(checksum_url)
    local sha256 = checksum_body:match("^%s*(%x+)")

    if not sha256 or #sha256 ~= 64 then
        error("Invalid SHA-256 checksum for " .. asset_name)
    end
    return {
        version = version,
        url = asset_url,
        sha256 = sha256:lower(),
    }
end

return M
