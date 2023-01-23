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
cache = {} -- global for debug reasons

local struct = {
    nodes_dug = 0,
    nodes_placed = 0,
}

-- helper funtions
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

-- (un)load/create data
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
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log("load: file of '" .. name .. "' does not exsist!")
        stats_create(name)
        file = io.open(datadir .. "/" .. name .. ".txt", "r")
    end
    local raw = file:read("*a")
    file:close()
    local data
    if raw == nil then
        log("load: file of '" .. name .. "' contains no data!")
    else
        data = minetest.deserialize(raw)
    end
    print("raw: " .. raw)
    print("data: " .. dump(data))
    -- CHECK IF ALL KEYS ARE IN STRUCT - ELSE ERROR
    cache[name] = data -- if no data, the cache[name] key will not created. How to fix that ???
    print(dump(cache))
end

function archtec_playerdata.unload(name)
    if not valid_player(name) then return end
    archtec_playerdata.save(name)
    cache[name] = nil
end

function archtec_playerdata.load_offline(name)
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log("load_offline: file of '" .. name .. "' does not exsist")
        -- do not create any data!
        return
    end
    local raw = file:read("*a")
    file:close()
    local data
    if raw == nil then
        log("load_offline: file of '" .. name .. "' contains no data!")
    else
        data = minetest.deserialize(raw)
    end
    print("raw: " .. raw)
    print("data: " .. dump(data))
    -- CHECK IF ALL KEYS ARE IN STRUCT - ELSE ERROR
    return data
end

-- save data
function archtec_playerdata.save(name)
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    if not file then
        log("save: file of '" .. name .. "' does not exsist!")
        return
    end
    local data = cache[name]
    local raw = minetest.serialize(data)
    file:write(raw)
    file:close()
    log("save: saved data of '" .. name .. "'")
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

minetest.register_on_shutdown(function()
    archtec_playerdata.save_all()
    log("shutdown: saved data!")
end)

-- get/set/mod data
function archtec_playerdata.get(name, key)
    if not valid_player(name) then return nil end
    if type(key) ~= "string" then
        log("get: key is not a string! '" .. key .. "'")
    end
    local val
    if cache[name] == nil then
        log("get: cache for '" .. name .. "' is nil!")
        return
    end
    if cache[name][key] == nil then -- nil crash, how to fix that ??? (fixed with the above nil check)
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
    if not valid_player(name) then return false end
    -- check for valid input (only numbers)
    if not type(value) == "number" then
        log("mod: value '" .. value .. "' is not a number!")
        return false
    end
    local old = archtec_playerdata.get(name, key)
    if old == nil then
        log("mod: get returned nil for key '" .. key .. "' of '" .. name .. "'!")
        return false
    end
    value = old + value
    cache[name][key] = value
    return true
end

-- test functions
minetest.register_on_dignode(function(_, _, digger)
    local name = digger:get_player_name()
    if name ~= nil then
        archtec_playerdata.mod(name, "nodes_dug", 1)
    end
end)

minetest.register_on_placenode(function(_, _, placer, _, _, _)
    local name = placer:get_player_name()
    if name ~= nil then
        archtec_playerdata.mod(name, "nodes_placed", 1)
    end
end)

-- /stats command for testing
function archtec_playerdata.get_formspec(name)
    local placed = archtec_playerdata.get(name, "nodes_placed")
    local dug = archtec_playerdata.get(name, "nodes_dug")

    local formspec = {
        "formspec_version[4]",
        "size[6,3.476]",
        "label[0.375,0.5;", minetest.formspec_escape("Placed: " .. placed), "]",
        "label[0.375,1.0;", minetest.formspec_escape("Dug: " .. dug), "]",
    }

    return table.concat(formspec, "")
end

minetest.register_chatcommand("stats", {
    func = function(name)
        minetest.show_formspec(name, "archtec_playerdata:stats", archtec_playerdata.get_formspec(name))
    end,
})
