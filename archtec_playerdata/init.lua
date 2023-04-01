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
local date = os.date
local C = minetest.colorize
local debug_mode = false

minetest.register_on_mods_loaded(function()
    if not minetest.mkdir(datadir) then
        error("[archtec_playerdata] Failed to create datadir directory '" .. datadir .. "'!")
    end
end)

-- struct: add new keys with default/fallback values! (Set always 0 (or a bool val) as fallback!)
local struct = {
    nodes_dug = 0,
    nodes_placed = 0,
    items_crafted = 0,
    died = 0,
    playtime = 0,
    chatmessages = 0,
    -- joined = 0, -- legacy -> use 'first_join'
    first_join = 0,
    join_count = 0,
    thank_you = 0
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

local function string2timestap(s)
    if type(s) ~= "string" then return end
    local p = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
    local p2 = "(%a+) (%a+)  (%d+) (%d+):(%d+):(%d+) (%d+)"
    local _, month, day, hour, min, sec, year = s:match(p)
    if day == nil then
        _, month, day, hour, min, sec, year = s:match(p2)
    end
    local MON = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
    local month = MON[month]
    local offset = time() - time(date("!*t"))
    -- Todo: fix possible crashes here
    return(time({day = day, month = month, year = year, hour = hour, min = min, sec = sec}) + offset)
end

archtec_playerdata.string2timestap = string2timestap

-- load/create data
local function stats_create(name)
    if not valid_player(name) then return end
    if stats_file_exsist(name) then
        log_warning("stats_create: stats for '" .. name .. "' already exsists!")
        return false
    end
    local file = io.open(datadir .. "/" .. name .. ".txt", "w")
    file:close()
    log_debug("stats_create: create stats file for '" .. name .. "'")
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
        log_warning("load: file of '" .. name .. "' contains no data!")
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

local function stats_load_offline(name) -- do not create/change any data of offline players!
    if not valid_player(name) then return end
    local file = io.open(datadir .. "/" .. name .. ".txt", "r")
    if not file then
        log_debug("load_offline: file of '" .. name .. "' does not exsist")
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
            log_debug("load_offline: (temporary) removing unknown key '" .. key .. "' of player '" .. name .. "'!")
            data[key] = nil -- remove unknown keys
        end
    end
    return data
end

-- get/set/mod data
local function stats_get(name, key)
    if not valid_player(name) then return end
    if type(key) ~= "string" then
        log_warning("get: key '" .. dump(key) .. "' is not a string!")
        return
    end
    local val
    if cache[name] == nil then
        log_warning("get: cache for '" .. name .. "' is nil!")
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

local function stats_set(name, key, value)
    if not valid_player(name) then return false end
    if not is_valid(value) then return false end
    if cache[name] == nil then
        log_warning("set: cache for '" .. name .. "' is nil!")
        return false
    end
    if value == struct[key] then
        value = nil
    end
    cache[name][key] = value
    return true
end

archtec_playerdata.set = stats_set

local function stats_mod(name, key, value)
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

-- save data
local function stats_save(name)
    if not valid_player(name) then return end
    -- update playtime
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
    log_debug("Took: " .. (after - before) / 1000 .. " ms")
    minetest.after(save_interval, stats_save_all)
end

minetest.after(4, stats_save_all)

-- unload helper
local function stats_unload(name)
    if not valid_player(name) then return end
    stats_save(name)
    cache[name] = nil
    playtime_current[name] = nil
end

-- load/save on player join/leave events
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        stats_load(name)
        stats_mod(name, "join_count", 1)
        -- playtime data migration
        if stats_get(name, "playtime") == 0 then
            stats_set(name, "playtime", player:get_meta():get_int("archtec:playtime"))
            player:get_meta():set_string("archtec:playtime", nil) -- remove playtime entry
            log_debug("on_joinplayer: removed 'archtec:playtime' meta of '" .. name .. "'")
        end
        -- first join data migration
		if stats_get(name, "first_join") == 0 then -- move legacy data
			local string = player:get_meta():get_string("archtec:joined")
            if string ~= "" or string == nil then
                local int = string2timestap(string)
                stats_set(name, "first_join", int)
                player:get_meta():set_string("archtec:joined", nil)
                log_debug("on_joinplayer: removed 'archtec:joined' meta of '" .. name .. "'")
            end
        end
        -- add first join
        if stats_get(name, "first_join") == 0 then
            stats_set(name, "first_join", time())
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if name ~= nil then
        stats_unload(name)
    end
end)

minetest.register_on_shutdown(function()
    stats_save_all()
    log_action("shutdown: saved all data!")
end)

-- stats
minetest.register_on_dignode(function(_, _, digger)
    if not digger then return end
    local name = digger:get_player_name()
    if name ~= nil then
        stats_mod(name, "nodes_dug", 1)
    end
end)

minetest.register_on_placenode(function(_, _, placer, _, _, _)
    if not placer then return end
    local name = placer:get_player_name()
    if name ~= nil then
        stats_mod(name, "nodes_placed", 1)
    end
end)

minetest.register_on_craft(function(_, player, _, _)
    if not player then return end
    local name = player:get_player_name()
    if name ~= nil then
        stats_mod(name, "items_crafted", 1)
    end
end)

minetest.register_on_dieplayer(function(player, _)
    if not player then return end
    local name = player:get_player_name()
    if name ~= nil then
        stats_mod(name, "died", 1)
    end
end)

local function stats(name, param)
    local target = param:trim()
    local data, is_online, user
    if target == "" or target == nil then
        target = name
    end
    if not minetest.player_exists(target) or not valid_player(target) then
        minetest.chat_send_player(name, C("#FF0000", "[stats] Unknown player!"))
        return
    end
    if in_cache(target) then
        data = table.copy(cache[target])
        is_online = true
    else
        data = stats_load_offline(target)
        is_online = false
    end
    if data == nil then
        minetest.chat_send_player(name, C("#FF0000", "[stats] Can't read stats!"))
        return
    end
    if data.join_count == nil then
        data.join_count = 1
    end
    local privs = minetest.get_player_privs(target) or {}
    local pauth = minetest.get_auth_handler().get_auth(target)
    local playtime_int = data.playtime or 1
    local avg = playtime_int / data.join_count or 1
    -- stats
    if is_online then user = target .. C("#00BD00", " [Online]") else user = target .. C("#FF0000", " [Offline]") end
    if privs["staff"] then user = user .. C("#FF8800", " [Staff]") end
    local nodes_dug = data.nodes_dug or 0
    local nodes_placed = data.nodes_placed or 0
    local crafted = data.items_crafted or 0
    local died = data.died or 0
    local playtime = format_duration(playtime_int) or 0
    local chatmessages = data.chatmessages or 0
    local first_join = date("!%Y-%m-%dT%H:%M:%SZ", data.first_join) .. " UTC"
    local join_count = data.join_count or 1
    local thank_you = data.thank_you or 0
    local avg_playtime = format_duration(avg) or 0
    local priv_lava, priv_chainsaw, priv_forceload, priv_areas, last_login
    if privs["adv_buckets"] then priv_lava = C("#00BD00", "YES") else priv_lava = C("#FF0000", "NO") end
    if privs["archtec_chainsaw"] then priv_chainsaw = C("#00BD00", "YES") else priv_chainsaw = C("#FF0000", "NO") end
    if privs["forceload"] then priv_forceload = C("#00BD00", "YES") else priv_forceload = C("#FF0000", "NO") end
    if privs["areas_high_limit"] then priv_areas = C("#00BD00", "YES") else priv_areas = C("#FF0000", "NO") end
    if pauth and pauth.last_login and pauth.last_login ~= -1 then
        last_login = date("!%Y-%m-%dT%H:%M:%SZ", pauth.last_login) .. " UTC"
    else
        last_login = "unknown"
    end
    local formspec = {
        "formspec_version[4]",
        "size[5,8.5]",
        "label[0.375,0.5;", fs_esc("Stats of: " .. user), "]",
        "label[0.375,1.0;", fs_esc("Dug: " .. nodes_dug), "]",
        "label[0.375,1.5;", fs_esc("Placed: " .. nodes_placed), "]",
        "label[0.375,2.0;", fs_esc("Crafted: " .. crafted), "]",
        "label[0.375,2.5;", fs_esc("Died: " .. died), "]",
        "label[0.375,3.0;", fs_esc("Playtime: " .. playtime), "]",
        "label[0.375,3.5;", fs_esc("Average playtime: " .. avg_playtime), "]",
        "label[0.375,4.0;", fs_esc("Chatmessages: " .. chatmessages), "]",
        "label[0.375,4.5;", fs_esc("Thank you: " .. thank_you), "]",
        "label[0.375,5.0;", fs_esc("Join date: " .. first_join), "]",
        "label[0.375,5.5;", fs_esc("Join count: " .. join_count), "]",
        "label[0.375,6.0;", fs_esc("Last login: " .. last_login), "]",
        "label[0.375,6.5;", fs_esc("Can spill lava: " .. priv_lava), "]",
        "label[0.375,7.0;", fs_esc("Can use the chainsaw: " .. priv_chainsaw), "]",
        "label[0.375,7.5;", fs_esc("Can place forceload blocks: " .. priv_forceload), "]",
        "label[0.375,8.0;", fs_esc("Can create big areas: " .. priv_areas), "]",
    }
    minetest.show_formspec(name, "archtec_playerdata:stats", table.concat(formspec, ""))
end

minetest.register_chatcommand("stats", {
    params = "<name>",
    description = "Shows player stats",
	privs = {interact = true},
    func = function(name, param)
        minetest.log("action", "[/stats] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
        stats(name, param)
    end,
})


--[[
Code example to migrate a key
local updated = 0

local function legacy_migrate_join_date(name)
    stats_load(name)
    local joined = stats_get(name, "joined")
    if joined ~= 0 then
        local int = string2timestap(joined)
        stats_set(name, "first_join", int)
        stats_set(name, "joined", 0)
        updated = updated + 1
        stats_unload(name)
    end
end

local function migrate()
    local files = minetest.get_dir_list(datadir)
    for _, file in pairs(files) do
        local name = string.sub(file, 1, #file - 4)
        legacy_migrate_join_date(name)
    end
    print(updated)
end

minetest.register_chatcommand("stats_migrate", {
	privs = {server = true},
    func = function(name, param)
        migrate()
    end,
})
]]--

