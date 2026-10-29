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
    local result = {}
    local page = 1

    while true do
        local body = get(M.api_url .. "/releases?per_page=100&page=" .. page)
        local releases = json.decode(body)

        if type(releases) ~= "table" then
            error("Invalid GitHub releases API response: expected an array")
        end

        if next(releases) ~= nil and releases.message then
            error("GitHub releases API error: " .. tostring(releases.message))
        end

        if #releases == 0 then
            break
        end

        for _, release in ipairs(releases) do
            if not release.draft and not release.prerelease then
                local version = release.tag_name:match("^jasypt%-(%d+%.%d+%.%d+)$")

                if version then
                    table.insert(result, {
                        version = version,
                        created_at = release.published_at,
                    })
                end
            end
        end

        if #releases < 100 then
            break
        end

        page = page + 1
    end

    return result
end

local function validate_version(version)
    if type(version) ~= "string" then
        error("Invalid version: expected a string, got " .. type(version), 0)
    end

    if version == "" then
        error("Invalid version: version cannot be empty", 0)
    end

    if not version:match("^%d+%.%d+%.%d+$") then
        error("Unsupported Jasypt version format: " .. version .. " (expected e.g. 1.9.3)", 0)
    end

    return version
end

function M.get_release(version)
    version = validate_version(version)
    local tag = "jasypt-" .. version

    local body = get(M.api_url .. "/releases/tags/" .. tag)
    local release = json.decode(body)

    if type(release) ~= "table" then
        error("Invalid release metadata for " .. tag .. ": expected a JSON object", 0)
    end

    if release.message then
        error("GitHub release API error for " .. tag .. ": " .. tostring(release.message), 0)
    end

    if type(release.tag_name) ~= "string" then
        error("Invalid release metadata for " .. tag .. ": missing tag_name", 0)
    end

    if release.tag_name ~= tag then
        error("Invalid release metadata for " .. tag .. ": tag_name mismatch", 0)
    end

    if type(release.assets) ~= "table" then
        error("Invalid release metadata for " .. tag .. ": assets is missing or not a list", 0)
    end

    if release.draft == nil or release.prerelease == nil then
        error("Invalid release metadata for " .. tag .. ": missing draft/prerelease flags", 0)
    end

    if release.draft or release.prerelease then
        error("Jasypt release is not a published stable release: " .. tag)
    end

    return release
end

function M.get_install_info(version)
    local release = M.get_release(version)
    local asset_name = "jasypt-" .. version .. "-dist.tar.gz"
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
