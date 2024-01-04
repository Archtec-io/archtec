--[[
	Copyright (C) 2023 Niklp <nik@niklp.net>
	GNU Lesser General Public License v2.1 See LICENSE.txt for more information
]]--

archtec_playerdata = {}
local sql = minetest.get_mod_storage()
local datadir = minetest.get_worldpath() .. "/archtec_playerdata"
local cache, playtime_current, rank = {}, {}, {}
local S = minetest.get_translator("archtec_playerdata")
local F = minetest.formspec_escape
local FS = function(...) return F(S(...)) end
local floor, type, C = math.floor, type, minetest.colorize
local rank_gentime = 0
local shutdown_mode = false

-- config
local save_interval = 180
local debug_mode = minetest.settings:get("archtec_playerdata.debug_mode", false)
local min_xp = 10000 -- modify by hand

-- struct: add new keys with default/fallback values! (Set always 0 (or a bool val) as fallback!)
local struct = {
	nodes_dug = 0,
	nodes_placed = 0,
	items_crafted = 0,
	died = 0,
	playtime = 0,
	chatmessages = 0,
	first_join = 0,
	join_count = 0,
	thank_you = 0,
	ignores = "",
	channels = "",
	free_votes = 0, -- we use 0 to allow later changes of the max value
	-- settings
	s_help_msg = true, -- help msg
	s_tbw_show = true, -- tool breakage warnings
	s_sp_show = true, -- spawnwaypoint
	s_r_id = true, -- auto item drop collection
	s_snow = true, -- enable snow particles
}

-- helper funtions
local function log_action(message)
	if message ~= "" then
		minetest.log("action", "[archtec_playerdata] " .. message)
	end
end

local function log_warning(message)
	if message ~= "" then
		minetest.log("warning", "[archtec_playerdata] " .. message)
		notifyTeam("[archtec_playerdata] Critical error! Please read the server logs!")
	end
end

local function log_debug(message)
	if debug_mode then
		if message ~= "" then
			minetest.log("warning", "[archtec_playerdata] " .. message)
		end
	end
end

local function valid_player(name)
	if name ~= nil and name ~= "" and type(name) == "string" then
		log_debug("valid_player: " .. dump(name) .. " is valid")
		return true
	else
		log_action("valid_player: " .. dump(name) .. " is not valid!") -- log_warning() would trigger staff notifications
		return false
	end
end

local function add_defaults(stats)
	local t = table.copy(stats)
	for k, v in pairs(struct) do
		if not t[k] then
			t[k] = v
		end
	end
	return t
end

local function in_struct(key)
	return struct[key] ~= nil
end

local function is_valid(value)
	local valtype = type(value)
	if valtype == "number" or valtype == "string" or valtype == "boolean" then
		return true
	end
	return false
end

local function divmod(a, b)
	return floor(a / b), a % b
end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

local function in_cache(name)
	return cache[name] ~= nil
end

local function get_session_playtime(name)
	if playtime_current[name] then
		return os.time() - playtime_current[name]
	else
		return 0
	end
end

local function format_int(number)
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")

	-- reverse the int-string back remove an optional comma and put the
	-- optional minus and fractional part back
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function stats_dump()
	local d = sql:to_table()
	local ts = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
	minetest.safe_file_write(datadir .. "/dump." .. ts, minetest.serialize(d))
end

minetest.register_chatcommand("stats_dump", {
	description = "Dump all stats",
	privs = {server = true},
	func = function(name)
		minetest.log("action", "[/stats_dump] executed by '" .. name .. "'")
		stats_dump()
		minetest.chat_send_player(name, C("#00BD00", "Dumped all stats"))
	end
})

archtec_playerdata.dump = stats_dump

local function stats_restore(name, table)
	local d = sql:to_table()
	d.fields[name] = minetest.serialize(table)
	sql:from_table(d)
end

archtec_playerdata.restore = stats_restore

local function string2timestamp(s)
	if type(s) ~= "string" then return end
	local p = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
	local p2 = "(%a+) (%a+)  (%d+) (%d+):(%d+):(%d+) (%d+)"
	local _, month, day, hour, min, sec, year = s:match(p)
	if day == nil then
		_, month, day, hour, min, sec, year = s:match(p2)
	end
	local MON = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
	month = MON[month]
	local offset = os.time() - os.time(os.date("!*t"))
	-- Todo: fix possible crashes here
	return(os.time({day = day, month = month, year = year, hour = hour, min = min, sec = sec}) + offset)
end

-- load/create data
local function stats_create(name)
	if sql:contains(name) then
		log_warning("stats_create: stats file for '" .. name .. "' already exsists!")
		return false
	end
	sql:set_string(name, minetest.serialize({}))
	return sql:contains(name)
end

local function stats_load(name, create)
	if not valid_player(name) then return end
	if create == nil then create = true end
	if cache[name] then
		log_action("load: stats of '" .. name .. "' already loaded")
		return
	end
	local raw = sql:get_string(name)
	if raw == "" then
		if not create then
			return
		end
		if stats_create(name) then
			raw = sql:get_string(name) -- try again
		else
			log_warning("load: cannot create stats entry for '" .. name .. "'!")
			return
		end
	end
	local data = minetest.deserialize(raw)
	if data == nil then
		log_warning("load: failed to deserialize stats of '" .. name .. "'!")
		return
	end
	-- remove unknown keys
	for key, _ in pairs(data) do
		if not (in_struct(key)) then
			log_action("load: removing unknown key '" .. key .. "' of player '" .. name)
			data[key] = nil
		end
	end
	cache[name] = data
end

-- save handler
local function stats_save(name)
	if not valid_player(name) then return end
	-- save data
	local data = cache[name]
	if data == nil then
		log_warning("save: cache for '" .. name .. "' is nil! Saving will be aborted!")
		return
	end
	local raw = minetest.serialize(data)
	if raw == nil or raw == "" then
		log_warning("save: raw data of '" .. name .. "' is nil!")
		return
	end
	sql:set_string(name, raw)
end

-- get default (global)
function archtec_playerdata.get_default(key)
	return struct[key]
end

-- get/set/mod data
local function stats_get(name, key)
	if not valid_player(name) then return end
	local val, clean
	if cache[name] == nil then
		stats_load(name, false)
		clean = true
		if cache[name] == nil then -- Player does not exist
			return struct[key]
		end
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
	if clean then
		cache[name] = nil
	end
	log_debug("get: return '" .. key .. "' of '" .. name .. "' with value '" .. dump(val) .. "'")
	return val
end

archtec_playerdata.get = stats_get

local function stats_set(name, key, value)
	if not valid_player(name) then return false end
	if not is_valid(value) then return false end
	local clean
	if not struct[key] then
		log_warning("set: tried to set unknown key '" .. key .. "'!")
		return false
	end
	if cache[name] == nil then
		stats_load(name, false)
		clean = true
		if cache[name] == nil then -- Player does not exist
			log_warning("set: tried to modify not existing player '" .. name .. "'!")
			return false
		end
	end
	if value == struct[key] then
		value = nil
	end
	cache[name][key] = value
	if clean then
		stats_save(name)
		cache[name] = nil
	end
	log_debug("set: set '" .. key .. "' of '" .. name .. "' to value '" .. dump(value) .. "'")
	return true
end

archtec_playerdata.set = stats_set

local function stats_mod(name, key, value)
	if not valid_player(name) then return false end
	if type(value) ~= "number" then
		log_warning("mod: value " .. dump(value) .. " is not a number!")
		return false
	end
	local old, clean
	if not struct[key] then
		log_warning("mod: tried to mod unknown key '" .. key .. "'!")
		return false
	end
	if cache[name] then
		if cache[name][key] then
			old = cache[name][key]
		else
			old = struct[key]
		end
	else
		stats_load(name, false)
		clean = true
		if cache[name] == nil then -- Player does not exist
			log_warning("mod: tried to modify not existing player '" .. name .. "'!")
			return false
		end
		if cache[name][key] then
			old = cache[name][key]
		else
			old = struct[key]
		end
	end
	local newval = old + value
	cache[name][key] = newval
	if clean then
		stats_save(name)
		cache[name] = nil
	end
	log_debug("mod: modify '" .. key .. "' of '" .. name .. "' to value '" .. newval .. "' (prev: '" .. old .. "' add: '" .. value .. "')")
	return true
end

archtec_playerdata.mod = stats_mod

-- save data
local function stats_save_all()
	local before = minetest.get_us_time()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		-- update playtime
		stats_mod(name, "playtime", get_session_playtime(name))
		playtime_current[name] = os.time()
		stats_save(name)
	end
	local after = minetest.get_us_time()
	log_debug("Took: " .. (after - before) / 1000 .. " ms")
	minetest.after(save_interval, stats_save_all)
end

local function stats_save_all_shutdown()
	local before = minetest.get_us_time()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		-- update playtime
		stats_mod(name, "playtime", get_session_playtime(name))
		playtime_current[name] = os.time()
		stats_save(name)
		cache[name] = nil
		playtime_current[name] = nil
	end
	local after = minetest.get_us_time()
	return (after - before) / 1000
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
			local time = player:get_meta():get_int("archtec:playtime")
			if time ~= nil and time ~= 0 and type(time) == "number" then
				stats_set(name, "playtime", time)
				player:get_meta():set_string("archtec:playtime", nil) -- remove playtime entry
				log_debug("on_joinplayer: removed 'archtec:playtime' meta of '" .. name .. "'")
			end
		end
		-- first join data migration
		if stats_get(name, "first_join") == 0 then -- move legacy data
			local string = player:get_meta():get_string("archtec:joined")
			if string ~= "" or string == nil then
				local int = string2timestamp(string)
				stats_set(name, "first_join", int)
				player:get_meta():set_string("archtec:joined", nil)
				log_debug("on_joinplayer: removed 'archtec:joined' meta of '" .. name .. "'")
			end
		end
		-- add first join
		if stats_get(name, "first_join") == 0 then
			stats_set(name, "first_join", os.time())
		end
		-- show spawn waypoint
		if stats_get(name, "s_sp_show") == true then
			archtec.sp_add(name)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	if shutdown_mode then return end -- Do not save anything
	local name = player:get_player_name()
	if name ~= nil then
		stats_unload(name)
	end
end)

minetest.register_on_shutdown(function()
	shutdown_mode = true
	local t = stats_save_all_shutdown()
	log_action("shutdown: saved all data in " .. t .. "ms!")
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

-- Stats formspec
-- 0 = conditions not fulfilled + w/o priv; 1 = conditions fulfilled + w/o priv; 2 = conditions fulfilled + w/ priv
local function colorize_privs(name, data, privs)
	local t = {priv_lava = 0, priv_chainsaw = 0, priv_forceload = 0, priv_areas = 0}
	-- priv_lava
	if data.playtime > archtec.adv_buckets_playtime then
		t.priv_lava = 1
	end
	if privs.adv_buckets then t.priv_lava = 2 end
	-- priv_chainsaw
	if archtec.chainsaw_conditions(name) then
		t.priv_chainsaw = 1
	end
	if privs.archtec_chainsaw then t.priv_chainsaw = 2 end
	-- priv_forceload (no check needed)
	if true then
		t.priv_forceload = 1
	end
	if privs.forceload then t.priv_forceload = 2 end
	-- priv_areas
	if data.playtime > archtec.big_areas_playtime then
		t.priv_areas = 1
	end
	if privs.areas_high_limit then t.priv_areas = 2 end

	local colorized = {}
	for priv, v in pairs(t) do
		if v == 0 then
			colorized[priv] = C("#FF0000", S("NO"))
		elseif v == 1 then
			colorized[priv] = C("#FF0", S("PENDING"))
		elseif v == 2 then
			colorized[priv] = C("#00BD00", S("YES"))
		end
	end
	return colorized.priv_lava or "", colorized.priv_chainsaw or "", colorized.priv_forceload or "", colorized.priv_areas or ""
end

local function stats_fs(name, target)
	local data, is_online, user
	if target == "" or target == nil then
		target = name
	end
	if not minetest.player_exists(target) or not valid_player(target) then
		minetest.chat_send_player(name, C("#FF0000", S("[stats] Unknown player!")))
		return
	end
	if in_cache(target) then
		data = table.copy(cache[target])
		is_online = true
	else
		stats_load(target, false) -- we won't create new stats files
		if cache[target] == nil then
			minetest.chat_send_player(name, C("#FF0000", S("[stats] Unknown player!")))
			return
		end
		data = table.copy(cache[target])
		cache[target] = nil -- unload
		is_online = false
	end
	if data == nil then
		minetest.chat_send_player(name, C("#FF0000", S("[stats] Can't read stats!")))
		return
	end
	-- prevent nil crashes
	data = add_defaults(data)
	-- get auth
	local privs = minetest.get_player_privs(target) or {}
	local pauth = minetest.get_auth_handler().get_auth(target)
	-- stats
	if is_online then user = target .. " " .. C("#00BD00", S("[Online]")) else user = target .. " " .. C("#FF0000", S("[Offline]")) end
	if privs["staff"] then user = user .. " " .. C("#FF8800", S("[Staff]")) end
	local nodes_dug = data.nodes_dug
	local nodes_placed = data.nodes_placed
	local crafted = data.items_crafted
	local died = data.died
	local playtime = format_duration(data.playtime)
	local chatmessages = data.chatmessages
	local first_join = os.date("!%Y-%m-%dT%H:%M:%SZ", data.first_join) .. " UTC"
	local join_count = data.join_count
	local thank_you = data.thank_you
	local avg_playtime = format_duration(data.playtime / data.join_count)
	local free_votes = archtec.free_votes - data.free_votes
	local priv_lava, priv_chainsaw, priv_forceload, priv_areas = colorize_privs(target, data, privs)
	local last_login
	if pauth and pauth.last_login and pauth.last_login ~= -1 then
		last_login = os.date("!%Y-%m-%dT%H:%M:%SZ", pauth.last_login) .. " UTC"
	else
		last_login = "unknown"
	end
	local formspec = [[
		formspec_version[4]
		size[5.5,9]
		label[0.375,0.5;]] .. FS("Stats of: @1", user) .. [[]
		label[0.375,1.0;]] .. FS("Dug: @1", nodes_dug) .. [[]
		label[0.375,1.5;]] .. FS("Placed: @1", nodes_placed) .. [[]
		label[0.375,2.0;]] .. FS("Crafted: @1", crafted) .. [[]
		label[0.375,2.5;]] .. FS("Died: @1", died) .. [[]
		label[0.375,3.0;]] .. FS("Playtime: @1", playtime) .. [[]
		label[0.375,3.5;]] .. FS("Average playtime: @1", avg_playtime) .. [[]
		label[0.375,4.0;]] .. FS("Chatmessages: @1", chatmessages) .. [[]
		label[0.375,4.5;]] .. FS("Thank you: @1", thank_you) .. [[]
		label[0.375,5.0;]] .. FS("Join date: @1", first_join) .. [[]
		label[0.375,5.5;]] .. FS("Join count: @1", join_count) .. [[]
		label[0.375,6.0;]] .. FS("Last login: @1", last_login) .. [[]
		label[0.375,6.5;]] .. FS("Can spill lava: @1", priv_lava) .. [[]
		label[0.375,7.0;]] .. FS("Can use the chainsaw: @1", priv_chainsaw) .. [[]
		label[0.375,7.5;]] .. FS("Can place forceload blocks: @1", priv_forceload) .. [[]
		label[0.375,8.0;]] .. FS("Can create big areas: @1", priv_areas) .. [[]
		label[0.375,8.5;]] .. FS("Remaining free votes: @1", free_votes) .. [[]
	]]
	minetest.show_formspec(name, "archtec_playerdata:stats", formspec)
end

minetest.register_chatcommand("stats", {
	params = "<name>",
	description = "Shows player stats",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/stats] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
		local target = param:trim()
		if target ~= name and archtec.ignore_check(name, target) then
			archtec.ignore_msg("stats", name, target)
			return
		end
		stats_fs(name, target)
	end
})

-- Ranking by XP
local function calc_xp(data)
	local xp = 0
	xp = xp + data.nodes_dug * 1.1
	xp = xp + data.nodes_placed * 1.6
	xp = xp + data.items_crafted * 0.7
	xp = xp - data.died * 25
	xp = xp + data.playtime * 0.1 -- 0.1 xp per second = 360 XP per hour
	xp = xp + data.chatmessages * 2
	xp = xp + data.thank_you * 100
	return floor(xp)
end

local function gen_ranking()
	rank = {}
	rank_gentime = os.time()
	-- collect data
	local data = sql:to_table().fields
	local users = {}
	for user, entry in pairs(data) do
		local stats = add_defaults(minetest.deserialize(entry) or {})
		local xp = calc_xp(stats)
		if xp >= min_xp then
			users[user] = {}
			users[user].name = user
			users[user].xp = xp
		end
	end
	-- sort data
	local sorted = {}
	for name, stats in pairs(users) do
		table.sort(stats, function(a, b) return a.xp > b.xp end)
		sorted[#sorted + 1] = {name, stats.xp}
	end
	table.sort(sorted, function(a, b) return a[2] > b[2] end)
	-- pre generate formspec entries for the first 100 players
	local place = 1
	for i = 1, 100 do
		if sorted[i] then
			local newstr = place .. ". " .. sorted[i][1] .. " - " .. format_int(sorted[i][2]) .. " XP"
			place = place + 1
			table.insert(rank, newstr)
		end
	end
end

local function rank_fs(sel)
	if rank_gentime < (os.time() - (60 * 60 * 6)) then -- re-generate after 6h
		gen_ranking()
	end

	local rows = {}
	local label = FS("Ranking generated at @1", os.date("!%Y-%m-%dT%H:%M:%SZ", rank_gentime) .. " UTC")

	local formspec = [[
		formspec_version[4]
		size[6,10]
		label[0.1,0.3;%s]
		tablecolumns[color;tree;text]
		table[0.1,0.5;5.8,9.4;list;%s;%i]
	]]

	-- add entries
	for _, str in ipairs(rank) do
		rows[#rows + 1] = "#7F7,0," .. F(str)
	end

	return formspec:format(label, table.concat(rows, ","), sel or 0)
end

minetest.register_chatcommand("rank", {
	description = "Get the XP of the best 100 players",
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/rank] executed by '" .. name .. "'")
		minetest.show_formspec(name, "archtec_playerdata:rank", rank_fs())
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec_playerdata:rank" or fields.quit then
		return
	end

	local event = minetest.explode_table_event(fields.list)
	if event.type ~= "INV" then
		local name = player:get_player_name()
		minetest.show_formspec(name, "archtec_playerdata:rank", rank_fs(event.row))
	end
end)

minetest.register_on_mods_loaded(function()
	if not minetest.mkdir(datadir) then
		error("[archtec_playerdata] Failed to create datadir directory '" .. datadir .. "'!")
	end
	stats_dump()
	gen_ranking()
end)