archtec_playerdata = {}
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
assert(minetest.mkdir(datadir), "[archtec_playerdata] Could not create playerdata directory " .. datadir)
cache = {} -- global for debug reasons

-- struct: add new keys with default/fallback values! (Set always 0 as fallback!)
local struct = {
    nodes_dug = 0,
    nodes_placed = 0,
    items_crafted = 0,
    died = 0,
    playtime = 0,
    chatmessages = 0,
    joined = 0,
}

-- helper funtions
local function log(message)
    if message ~= nil and message ~= "" then
        minetest.log("warning", "[archtec_playerdata] " .. message)
    end
end

local function valid_player(name)
    if name ~= nil and name ~= "" and type(name) == "string" then
        -- log("valid_player: '" .. name .. "' is valid!")
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

local function in_struct(key)
    return struct[key] ~= nil
end

local function is_valid(value)
    local valtype = type(value)
    if valtype == "number" or valtype == "string" or valtype == "boolean" then
        return true
    else
        return false
    end
end

local function trim(s)
    return s:match"^%s*(.*)":match"(.-)%s*$"
end

-- (un)load/create data
local function stats_create(name)
    if not valid_player(name) then return end
    if stats_file_exsist(name) then
        log("stats_create: stats for '" .. name .. "' already exsists!")
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
        file = io.open(datadir .. "/" .. name .. ".txt", "r") -- try again
    end
    local raw = file:read("*a")
    file:close()
    local data
    if raw == nil then
        log("load: file of '" .. name .. "' contains no data!")
    else
        data = minetest.deserialize(raw)
        if data == nil then
            data = {} -- fix nil crashes due non-existing keys
        end
    end
    -- print("raw: " .. raw)
    -- print("data: " .. dump(data))
    for key, value in pairs(data) do
        if not (in_struct(key)) then
            log("load: removing unknown key '" .. key .. "' of player '" .. name .. "'!")
            data[key] = nil -- remove unknown keys
        end
    end
    cache[name] = data
    -- print(dump(cache))
end

function archtec_playerdata.unload(name)
    if not valid_player(name) then return end
    archtec_playerdata.save(name)
    cache[name] = nil
end

function archtec_playerdata.load_offline(name) -- do not create/change any data of offline players!
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log("load_offline: file of '" .. name .. "' does not exsist")
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
    -- print("raw: " .. raw)
    -- print("data: " .. dump(data))
    for key, value in pairs(data) do
        if not (in_struct(key)) then
            log("load_offline: (temporary) removing unknown key '" .. key .. "' of player '" .. name .. "'!")
            data[key] = nil -- remove unknown keys
        end
    end
    return data
end

function archtec_playerdata.in_cache(name)
    if not valid_player(name) then return false end
    if cache[name] ~= nil then
        return true
    else
        return false
    end
end

-- save data
function archtec_playerdata.save(name)
    if not valid_player(name) then return end
    local data = cache[name]
    -- save only if things changed (via table.concat)
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    if not file then
        log("save: file of '" .. name .. "' does not exsist!")
        return
    end
    local raw = minetest.serialize(data)
    if raw == nil then
        log("save: raw data of '" .. name .. "' is nil!")
        return
    end
    file:write(raw)
    file:close()
    log("save: saved data of '" .. name .. "'")
end

function archtec_playerdata.save_all()
    local before = minetest.get_us_time()
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        archtec_playerdata.save(name)
        archtec.playtimesave(name)
    end
    local after = minetest.get_us_time()
    print("Took: " .. (after-before) / 1000 .. " ms")
    minetest.after(20, archtec_playerdata.save_all)
    print(dump(cache))
end

minetest.after(6, archtec_playerdata.save_all)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        archtec_playerdata.load(name)
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        archtec_playerdata.unload(name)
    end
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
    if not valid_player(name) then return false end
    if not is_valid(value) then return end
    if cache[name] == nil then
        log("set: cache for '" .. name .. "' is nil!")
        return false
    end
    cache[name][key] = value
    return true
end

function archtec_playerdata.mod(name, key, value)
    if not valid_player(name) then return false end
    if type(value) ~= "number" then
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

minetest.register_on_craft(function(_, player, _, _)
    local name = player:get_player_name()
    if name ~= nil then
        archtec_playerdata.mod(name, "items_crafted", 1)
    end
end)

minetest.register_on_dieplayer(function(player, _)
    local name = player:get_player_name()
    if name ~= nil then
        archtec_playerdata.mod(name, "died", 1)
    end
end)

local function stats(name, param) -- check for valid player doesn't work
    local target = trim(param)
    local data
    if target == "" or target == nil then
        target = name
    end
    if not minetest.player_exists(target) or not valid_player(target) then
        return("[stats]: Unknown player!")
    end
    if archtec_playerdata.in_cache(target) then
        data = table.copy(cache[target])
    else
        data = archtec_playerdata.load_offline(target)
    end
    if data == nil then
        return("[stats]: Can't read stats!")
    end
    local nodes_dug = data.nodes_dug or 0
    local nodes_placed = data.nodes_placed or 0
    local crafted = data.items_crafted or 0
    local died = data.died or 0
    local playtime = archtec.get_total_playtime_format(target) or 0
    local chatmessages = data.chatmessages or 0
    local joined = data.joined or 0
    local formspec = {
        "formspec_version[4]",
        "size[5,4.5]",
        "label[0.375,0.5;", minetest.formspec_escape("Stats of: " .. target), "]",
        "label[0.375,1.0;", minetest.formspec_escape("Dug: " .. nodes_dug), "]",
        "label[0.375,1.5;", minetest.formspec_escape("Placed: " .. nodes_placed), "]",
        "label[0.375,2.0;", minetest.formspec_escape("Crafted: " .. crafted), "]",
        "label[0.375,2.5;", minetest.formspec_escape("Died: " .. died), "]",
        "label[0.375,3.0;", minetest.formspec_escape("Playtime: " .. playtime), "]",
        "label[0.375,3.5;", minetest.formspec_escape("Chatmessages: " .. chatmessages), "]",
        "label[0.375,4.0;", minetest.formspec_escape("Join date: " .. joined), "]",
    }
    return table.concat(formspec, "")
end

minetest.register_chatcommand("stats", {
    func = function(name, param)
        minetest.show_formspec(name, "archtec_playerdata:stats", stats(name, param))
    end,
})
