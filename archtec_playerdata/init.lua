--[[ Doc:
function archtec_playerdata.set(name, key, value)
    - name is a playername
    - key is an identifier
    - value is the data (number, string, boolean)
]]--
-- player = ObjectRef, name = playername
-- set, get, mod

archtec_playerdata = {}
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
assert(minetest.mkdir(datadir), "[archtec_playerdata] Could not create playerdata directory " .. datadir)
cache = {}

local struct = {
    nodes_dug = 0,
    name = "unknown"
}

local function log(message)
    if message ~= nil and message ~= "" then
        minetest.log("warning", "[archtec_playerdata] " .. message)
    end
end

local function valid_player(name)
    if name ~= nil and name ~= "" and type(name) == "string" then
        --log("valid_player: '" .. name .. "' is valid!")
        return true
    else
        log("valid_player: '" .. name .. "' is not valid!")
        return false
    end
end

local function stats_file_exsist(name)
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if file ~= nil then
        file:close()
        log("stats_file_exsist: file of '" .. name .. "' exsits")
        return true 
    else 
        log("stats_file_exsist: file of '" .. name .. "' does not exsit")
        return false 
    end
end

local function stats_create(name)
    if not valid_player(name) then return end
    if stats_file_exsist(name) then
        log("stats_create: stats for '" .. name .. "' already exsists")
        return false
    end
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    file:close()
    log("stats_create: create stats file for '" .. name .. "'")
    return true
end

function archtec_playerdata.load(name)
    if not valid_player(name) then return end
    if not stats_file_exsist(name) then
        stats_create(name)
    end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    local raw = file:read("*all")
    file:close()
    local data = {}
    if not raw == nil and not raw == "" then
        data = minetest.deserialize(raw)
    end
    --if data == nil then -- hack to prevent nil cache (???)
       -- data[name] = name
    --end
    cache[name] = data
    print(dump(cache))
end

function archtec_playerdata.unload(name)
    if not valid_player(name) then return end
    archtec_playerdata.save(name)
    cache[name] = nil
end

function archtec_playerdata.save(name)
    if not valid_player(name) then return end
    if not stats_file_exsist(name) then
        log("save: file of '" .. name .. "' does not exsist")
        return
    end
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    local raw = minetest.serialize(cache[name])
    file:write(raw)
    file:close()
end

function archtec_playerdata.save_all()
    local before = minetest.get_us_time()
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        archtec_playerdata.save(name)
    end
    local after = minetest.get_us_time()
    print("Took: " .. (after-before) / 1000 .. " ms")
    minetest.after(20, archtec_playerdata.save_all)
    print(dump(cache))
end

minetest.after(6, archtec_playerdata.save_all)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    archtec_playerdata.load(name)
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    archtec_playerdata.unload(name)
end)

function archtec_playerdata.get(name, key)
    if not valid_player(name) then return nil end
    if type(key) ~= "string" then
        log("get: key is not a string! '" .. key .. "'")
    end
    local val = nil
    if cache[name][key] == nil then
        val = struct[key]
    else
        val = cache[name][key]
    end
    if val == nil then
        log("get: key '" .. key .. "' is unknown!")
        return nil
    end
    return val
end

function archtec_playerdata.set(name, key, value)
    if not valid_player(name) then return nil end
    -- check for valid input
    cache[name][key] = value
    return true
end

function archtec_playerdata.mod(name, key, value)
    if not valid_player(name) then return nil end
    -- check for valid input (only numbers)
    local old = archtec_playerdata.get(name, key)
    value = old + value
    cache[name][key] = value
    return true
end

minetest.register_on_dignode(function(_, _, digger)
    local name = digger:get_player_name()
    archtec_playerdata.mod(name, "nodes_dug", 1)
end)
