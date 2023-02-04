--[[
    Copyright (C) 2023 Niklp
    GNU Lesser General Public License v2.1 See LICENSE.txt for more information
]]--

archtec_playerdata = {}
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
local cache = {}
local playtime_current = {}
local fs_esc = minetest.formspec_escape
local save_interval = 60
local floor = math.floor
local time = os.time
local debug_mode = false

minetest.register_on_mods_loaded(function()
    if not minetest.mkdir(datadir) then
		error("[archtec_playerdata] Failed to create datadir directory '" .. datadir .. "'!")
	end
end)

-- struct: add new keys with default/fallback values! (Set always 0 as fallback!)
local struct = {
    nodes_dug = 0,
    nodes_placed = 0,
    items_crafted = 0,
    died = 0,
    playtime = 0,
    chatmessages = 0,
    joined = 0,
    join_count = 0
}

-- helper funtions
local function log_action(message)
    if message ~= nil and message ~= "" then
        minetest.log("action", "[archtec_playerdata] " .. message)
    end
end

local function log_warning(message)
    if message ~= nil and message ~= "" then
        minetest.log("warning", "[archtec_playerdata] " .. message)
    end
end

local function log_debug(message)
    if debug_mode then
        if message ~= nil and message ~= "" then
            minetest.log("warning", "[archtec_playerdata] " .. message)
        end
    end
end

local function valid_player(name)
    if name ~= nil and name ~= "" and type(name) == "string" then
        log_debug("valid_player: '" .. name .. "' is valid!")
        return true
    else
        log_warning("valid_player: '" .. name .. "' is not valid!")
        return false
    end
end

local function stats_file_exsist(name)
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if file ~= nil then
        file:close()
        log_debug("stats_file_exsist: file of '" .. name .. "' exsits")
        return true
    else
        log_debug("stats_file_exsist: file of '" .. name .. "' does not exsit")
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

local function divmod(a, b)
    if type(a) ~= "number" or type(b) ~= "number" then
        return
    end
    return floor(a / b), a % b
end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

local function in_cache(name)
    if not valid_player(name) then return false end
    if cache[name] ~= nil then
        return true
    else
        return false
    end
end

local function get_session_playtime(name)
	if playtime_current[name] then
		return time() - playtime_current[name]
	else
		return 0
	end
end

local function month2int(name)
    local months = {Jan = 01, Feb = 02, Mar = 03, Apr = 04, May = 05, Jun = 06, Jul = 07, Aug = 08, Sep = 09, Oct = 10, Nov = 11, Dec = 12}
    for key, value in pairs(months) do
        if key == name then
            return months[key]
        end
    end
end

local function string2timestap(monthstring)
    if type(monthstring) ~= "string" then return end
    local _, rday, rmonth, ryear, rhour, rminute, rsecond, _ = string.match(monthstring, "(%a+) (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) (%a+)")
    rmonth = month2int(rmonth) or 01
    local convertedTimestamp = time({year = ryear, month = rmonth, day = rday, hour = rhour, min = rminute, sec = rsecond})
    return convertedTimestamp
end

archtec_playerdata.string2timestap = string2timestap

-- save data
local function stats_save(name)
    if not valid_player(name) then return end
    stats_mod(name, "playtime", get_session_playtime(name))
    playtime_current[name] = time()
    local data = cache[name]
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    if not file then
        log_warning("save: file of '" .. name .. "' does not exsist!")
        return
    end
    local raw = minetest.serialize(data)
    if raw == nil then
        log_warning("save: raw data of '" .. name .. "' is nil!")
        return
    end
    file:write(raw)
    file:close()
end

local function stats_save_all()
    local before = minetest.get_us_time()
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        stats_save(name)
    end
    local after = minetest.get_us_time()
    log_debug("Took: " .. (after-before) / 1000 .. " ms")
    minetest.after(save_interval, stats_save_all)
end

minetest.after(4, stats_save_all)

-- (un)load/create data
local function stats_create(name)
    if not valid_player(name) then return end
    if stats_file_exsist(name) then
        log_warning("stats_create: stats for '" .. name .. "' already exsists!")
        return false
    end
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    file:close()
    log_action("stats_create: create stats file for '" .. name .. "'")
    return true
end

local function stats_load(name)
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log_debug("load: file of '" .. name .. "' does not exsist!")
        stats_create(name)
        file = io.open(datadir .. "/" .. name .. ".txt", "r") -- try again
    end
    local raw = file:read("*a")
    file:close()
    local data
    if raw == nil then
        log_warning("load: file of '" .. name .. "' contains no data!") -- ???
    else
        data = minetest.deserialize(raw)
        if data == nil then
            data = {} -- fix nil crashes due non-existing keys
        end
    end
    for key, value in pairs(data) do
        if not (in_struct(key)) then
            log_warning("load: removing unknown key '" .. key .. "' of player '" .. name .. "'!")
            data[key] = nil -- remove unknown keys
        end
    end
    cache[name] = data
end

local function stats_unload(name)
    if not valid_player(name) then return end
    stats_save(name)
    cache[name] = nil
end

local function stats_load_offline(name) -- do not create/change any data of offline players!
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log_action("load_offline: file of '" .. name .. "' does not exsist")
        return
    end
    local raw = file:read("*a")
    file:close()
    local data
    if raw == nil then
        log_warning("load_offline: file of '" .. name .. "' contains no data!")
        return
    else
        data = minetest.deserialize(raw)
    end
    for key, value in pairs(data) do
        if not (in_struct(key)) then
            log_action("load_offline: (temporary) removing unknown key '" .. key .. "' of player '" .. name .. "'!")
            data[key] = nil -- remove unknown keys
        end
    end
    return data
end

-- load/save on player join/leave events
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        stats_load(name)
        stats_mod(name, "join_count", 1)
        if stats_get(name, "playtime") == 0 then
            local meta = player:get_meta()
            stats_set(name, "playtime", player:get_meta():get_int("archtec:playtime"))
            meta:set_string("archtec:playtime", nil) -- remove playtime entry
            log_warning("on_joinplayer: removed playtime meta of '" .. name .. "'")
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        stats_unload(name)
        playtime_current[name] = nil
    end
end)

minetest.register_on_shutdown(function()
    stats_save_all()
    log_action("shutdown: saved all data!")
end)

-- get/set/mod data
function stats_get(name, key)
    if not valid_player(name) then return end
    if type(key) ~= "string" then
        log_warning("get: key is not a string! '" .. key .. "'")
    end
    local val
    if cache[name] == nil then
        log_debug("get: cache for '" .. name .. "' is nil!")
        return
    end
    if cache[name][key] == nil then
        val = struct[key]
    else
        val = cache[name][key]
    end
    if val == nil then
        log_warning("get: key '" .. key .. "' is unknown!")
        return
    end
    return val
end

archtec_playerdata.get = stats_get

function stats_set(name, key, value)
    if not valid_player(name) then return false end
    if not is_valid(value) then return false end
    if cache[name] == nil then
        log_warning("set: cache for '" .. name .. "' is nil!")
        return false
    end
    cache[name][key] = value
    return true
end

archtec_playerdata.set = stats_set

function stats_mod(name, key, value)
    if not valid_player(name) then return false end
    if type(value) ~= "number" then
        log_warning("mod: value '" .. value .. "' is not a number!")
        return false
    end
    local old = stats_get(name, key)
    if old == nil then
        log_warning("mod: get returned nil for key '" .. key .. "' of '" .. name .. "'!")
        return false
    end
    value = old + value
    cache[name][key] = value
    return true
end

archtec_playerdata.mod = stats_mod

-- stats
minetest.register_on_dignode(function(_, _, digger)
    local name = digger:get_player_name()
    if name ~= nil then
        stats_mod(name, "nodes_dug", 1)
    end
end)

minetest.register_on_placenode(function(_, _, placer, _, _, _)
    local name = placer:get_player_name()
    if name ~= nil then
        stats_mod(name, "nodes_placed", 1)
    end
end)

minetest.register_on_craft(function(_, player, _, _)
    local name = player:get_player_name()
    if name ~= nil then
        stats_mod(name, "items_crafted", 1)
    end
end)

minetest.register_on_dieplayer(function(player, _)
    local name = player:get_player_name()
    if name ~= nil then
        stats_mod(name, "died", 1)
    end
end)

local function stats(name, param) -- check for valid player doesn't work
    local target = param:trim()
    local data
    if target == "" or target == nil then
        target = name
    end
    if not minetest.player_exists(target) or not valid_player(target) then
        minetest.chat_send_player(name, "[stats]: Unknown player!")
        return
    end
    if in_cache(target) then
        data = table.copy(cache[target])
    else
        data = stats_load_offline(target)
    end
    if data == nil then
        minetest.chat_send_player(name, "[stats]: Can't read stats!")
        return
    end
    if data.join_count == nil then
        data.join_count = 1
    end
    local privs = minetest.get_player_privs(target) or {}
    local playtime_int = data.playtime or 1
    local avg = playtime_int / data.join_count or 1
    -- stats
    local nodes_dug = data.nodes_dug or 0
    local nodes_placed = data.nodes_placed or 0
    local crafted = data.items_crafted or 0
    local died = data.died or 0
    local playtime = format_duration(playtime_int) or 0
    local chatmessages = data.chatmessages or 0
    local joined = data.joined or 0
    local join_count = data.join_count or 1
    local avg_playtime = format_duration(avg) or 0
    local priv_lava, priv_chainsaw, priv_forceload, priv_areas
    if privs["adv_buckets"] then priv_lava = "YES" else priv_lava = "NO" end
    if privs["archtec_chainsaw"] then priv_chainsaw = "YES" else priv_chainsaw = "NO" end
    if privs["forceload"] then priv_forceload = "YES" else priv_forceload = "NO" end
    if privs["areas_high_limit"] then priv_areas = "YES" else priv_areas = "NO" end
    local formspec = {
        "formspec_version[4]",
        "size[5,7.5]",
        "label[0.375,0.5;", fs_esc("Stats of: " .. target), "]",
        "label[0.375,1.0;", fs_esc("Dug: " .. nodes_dug), "]",
        "label[0.375,1.5;", fs_esc("Placed: " .. nodes_placed), "]",
        "label[0.375,2.0;", fs_esc("Crafted: " .. crafted), "]",
        "label[0.375,2.5;", fs_esc("Died: " .. died), "]",
        "label[0.375,3.0;", fs_esc("Playtime: " .. playtime), "]",
        "label[0.375,3.5;", fs_esc("Average playtime: " .. avg_playtime), "]",
        "label[0.375,4.0;", fs_esc("Chatmessages: " .. chatmessages), "]",
        "label[0.375,4.5;", fs_esc("Join date: " .. joined), "]",
        "label[0.375,5.0;", fs_esc("Join count: " .. join_count), "]",
        "label[0.375,5.5;", fs_esc("Can spill lava: " .. priv_lava), "]",
        "label[0.375,6.0;", fs_esc("Can use the chainsaw: " .. priv_chainsaw), "]",
        "label[0.375,6.5;", fs_esc("Can place forceload blocks: " .. priv_forceload), "]",
        "label[0.375,7.0;", fs_esc("Can create big areas: " .. priv_areas), "]",
    }
    minetest.show_formspec(name, "archtec_playerdata:stats", table.concat(formspec, ""))
end

minetest.register_chatcommand("stats", {
    description = "Shows player stats",
	privs = {interact = true},
    func = function(name, param)
        stats(name, param)
    end,
})
