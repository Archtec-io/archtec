--[[ Doc:
function archtec_playerdata.set(name, key, value)
    - name is a playername
    - key is an identifier
    - value is the data (nil, number, string, boolean, table)
]]--

archtec_playerdata = {}
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
assert(minetest.mkdir(datadir), "[archtec_playerdata] Could not create playerdata directory " .. datadir)

local cache = {}

function archtec_playerdata.load(name)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "r")
    local raw
    if file == nil then
        return false
    end
    if file ~= nil then
        raw = file:read()
        io.close(file)
    end
    local data = minetest.deserialize(raw)
    cache[name] = data
end

function archtec_playerdata.save(name)
    local path = datadir .. "/" .. name .. ".txt"
    local file = io.open(path, "w")
    local data = cache[name]
    local raw = minetest.serialize(data)
    file:write(raw)
    io.close(file)
end

function archtec_playerdata.get(name, key)
    local value = cache[name[key]]
    return value
end

function archtec_playerdata.set(name, key, value)
    cache[name[key]] = value
    return true
end

minetest.register_on_joinplayer(function(player)
    if player == nil then return end
    local name = player:get_player_name()
    archtec_playerdata.load(name)
end)

minetest.register_on_leaveplayer(function(player)
    if player == nil then return end
    local name = player:get_player_name()
	cache[name] = nil
end)