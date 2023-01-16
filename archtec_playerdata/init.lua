--[[ Doc:
function archtec_playerdata.set(name, key, value)
    - name is a playername
    - key is an identifier
    - value is the data (nil, number, string, boolean, table)
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

function archtec_playerdata.get(name, key, default)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "r")
    local raw
    if file == nil then
        archtec_playerdata.create(name)
    end
    if file ~= nil then
        raw = file:read()
        io.close(file)
    end
    local data = minetest.deserialize(raw)
    local value
    if data == nil then
        archtec_playerdata.set(name, key, default)
        value = default
    else
        value = data[key]
    end
    return value
end

function archtec_playerdata.set(name, key, value)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "w")
    local raw = file:read()
    local data = minetest.deserialize(raw)
    if raw and data == nil then
        data = {}
    end
    data[key] = value
    local new = minetest.serialize(data)
    file:write(new)
    io.close(file)
    return true
end
