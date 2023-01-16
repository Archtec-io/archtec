--[[ Todo
-- value support
-- cache
]]--
archtec_playerdata = {}
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
assert(minetest.mkdir(datadir), "[archtec_playerdata] Could not create playerdata directory " .. datadir)

function archtec_playerdata.create(name)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "w")
    io.close(file)
    return true
end

function archtec_playerdata.get(name)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "r")
    if file == nil then
        archtec_playerdata.create(name)
        return false
    end
    local raw = file:read()
    if file ~= nil then
        io.close(file)
    end
    local data = minetest.deserialize(raw)
    return data
end

function archtec_playerdata.set(name, data)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "w")
    local new = minetest.serialize(data)
    file:write(new)
    io.close(file)
    return true
end