local S = archtec.S
local F = core.formspec_escape
local FS = function(...) return F(S(...)) end
local C = core.colorize
local mod = archtec_playerdata.mod

-- Helper functions
local function divmod(a, b)
	return math.floor(a / b), a % b
end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

-- Player activity stats
local uses_choppy = {}
choppy.api.register_before_chop(function(self, player, pos, node)
	uses_choppy[player:get_player_name()] = true
end)

choppy.api.register_after_chop(function(self, player, pos, node)
	uses_choppy[player:get_player_name()] = nil
end)

archtec_playerdata.register_key("nodes_dug", "number", 0)
core.register_on_dignode(function(_, _, digger)
	if not digger then return end
	local name = digger:get_player_name()
	if name ~= nil and uses_choppy[name] == nil then
		mod(name, "nodes_dug", 1)
	end
end)

archtec_playerdata.register_key("nodes_placed", "number", 0)
core.register_on_placenode(function(_, _, placer, _, _, _)
	if not placer then return end
	local name = placer:get_player_name()
	if name ~= nil then
		mod(name, "nodes_placed", 1)
	end
end)

archtec_playerdata.register_key("items_crafted", "number", 0)
core.register_on_craft(function(_, player, _, _)
	if not player then return end
	local name = player:get_player_name()
	if name ~= nil then
		mod(name, "items_crafted", 1)
	end
end)

archtec_playerdata.register_key("died", "number", 0)
core.register_on_dieplayer(function(player, _)
	if not player then return end
	local name = player:get_player_name()
	if name ~= nil then
		mod(name, "died", 1)
	end
end)

-- Stats formspec
local function colorize_privs(name, data, privs)
	local t = {lava = 0, chainsaw = 0, forceload = 0, areas = 0}
	-- lava
	if data.playtime > archtec.adv_buckets_playtime then t.lava = 1 end
	if privs.adv_buckets then t.lava = 2 end

	-- chainsaw
	if archtec.chainsaw_conditions(name) then t.chainsaw = 1 end
	if privs.archtec_chainsaw then t.chainsaw = 2 end

	-- forceload (no check needed)
	t.forceload = 1
	if privs.forceload then t.forceload = 2 end

	-- areas
	if data.playtime > archtec.big_areas_playtime then t.areas = 1 end
	if privs.areas_high_limit then t.areas = 2 end

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
	return colorized
end

local function stats_formspec(name, target)
	local data = archtec_playerdata.get_all(target)
	local auth = core.get_auth_handler().get_auth(target)
	local privs = core.get_player_privs(target)
	if data == nil then -- can happen when the user never joined after archtec_player was enabled
		core.chat_send_player(name, C("#FF0000", S("[stats] Failed to load stats!")))
		return
	end

	local tags
	if core.get_player_by_name(target) then
		tags = C("#00BD00", S("[Online]"))
	else
		tags = C("#FF0000", S("[Offline]"))
	end
	if privs.staff then
		tags = tags .. " " .. C("#FF8800", S("[Staff]"))
	end
	if privs.builder then
		tags = tags .. " " .. C("#00BD00", S("[Builder]"))
	end

	-- Format some values
	local playtime = format_duration(data.playtime)
	local avg_playtime = format_duration(data.playtime / data.join_count)
	local first_join = os.date("!%Y-%m-%d %H:%M", data.first_join) .. " UTC"
	local free_votes = archtec.free_votes - data.free_votes

	local last_login
	if auth and auth.last_login then
		last_login = os.date("!%Y-%m-%d %H:%M", auth.last_login) .. " UTC"
	else
		last_login = "unknown"
	end

	local xp = archtec.calc_xp(data)
	local privs_color = colorize_privs(target, data, privs)

	-- Generate formspec
	local formspec = {
		"formspec_version[3]",
		"size[10,6]",
		"box[0.3,0.3;9.4,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. FS("Stats of: @1 - @2 XP @3", target, archtec.format_int(xp), tags) .. "]",

		"label[0.4,1.2;" .. FS("Nodes dug: @1", archtec.format_int(data.nodes_dug)) .. "]",
		"label[0.4,1.8;" .. FS("Nodes placed: @1", archtec.format_int(data.nodes_placed)) .. "]",
		"label[0.4,2.4;" .. FS("Crafted items: @1", archtec.format_int(data.items_crafted)) .. "]",
		"label[0.4,3.0;" .. FS("Died: @1", archtec.format_int(data.died)) .. "]",
		"label[0.4,3.6;" .. FS("Chatmessages: @1", archtec.format_int(data.chatmessages)) .. "]",
		"label[0.4,4.2;" .. FS("Thank you: @1", archtec.format_int(data.thank_you)) .. "]",
		"label[0.4,4.8;" .. FS("Playtime: @1", playtime) .. "]",
		"label[0.4,5.4;" .. FS("Average playtime: @1", avg_playtime) .. "]",

		"label[5.0,1.2;" .. FS("Join count: @1", archtec.format_int(data.join_count)) .. "]",
		"label[5.0,1.8;" .. FS("First join: @1", first_join) .. "]",
		"label[5.0,2.4;" .. FS("Last login: @1", last_login) .. "]",
		"label[5.0,3.0;" .. FS("Remaining free votes: @1", free_votes) .. "]",
		"label[5.0,3.6;" .. FS("Can spill lava: @1", privs_color.lava) .. "]",
		"label[5.0,4.2;" .. FS("Can use the chainsaw: @1", privs_color.chainsaw) .. "]",
		"label[5.0,4.8;" .. FS("Can forceload areas: @1", privs_color.forceload) .. "]",
		"label[5.0,5.4;" .. FS("Can create big areas: @1", privs_color.areas) .. "]",
	}

	core.show_formspec(name, "archtec_playerdata:stats", table.concat(formspec))
end

core.register_chatcommand("stats", {
	params = "<name>",
	description = S("Shows stats of <name>"),
	privs = {interact = true},
	func = function(name, param)
		core.log("action", "[/stats] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = param:trim()
		if target == "" then
			target = name
		end
		if not core.player_exists(target) then
			core.chat_send_player(name, C("#FF0000", S("[stats] Unknown player!")))
			return
		end
		if not archtec_playerdata.player_exists(target) then
			core.chat_send_player(name, C("#FF0000", S("[stats] Failed to load stats!")))
			return
		end
		if target ~= name and archtec.ignore_check(name, target) then
			archtec.ignore_msg("stats", name, target)
			return
		end
		stats_formspec(name, target)
	end
})
