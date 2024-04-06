local S = minetest.get_translator("archtec_playerdata")
local F = minetest.formspec_escape
local FS = function(...) return F(S(...)) end
local C = minetest.colorize
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

local function format_int(number)
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
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
minetest.register_on_dignode(function(_, _, digger)
	if not digger then return end
	local name = digger:get_player_name()
	if name ~= nil and uses_choppy[name] == nil then
		mod(name, "nodes_dug", 1)
	end
end)

archtec_playerdata.register_key("nodes_placed", "number", 0)
minetest.register_on_placenode(function(_, _, placer, _, _, _)
	if not placer then return end
	local name = placer:get_player_name()
	if name ~= nil then
		mod(name, "nodes_placed", 1)
	end
end)

archtec_playerdata.register_key("items_crafted", "number", 0)
minetest.register_on_craft(function(_, player, _, _)
	if not player then return end
	local name = player:get_player_name()
	if name ~= nil then
		mod(name, "items_crafted", 1)
	end
end)

archtec_playerdata.register_key("died", "number", 0)
minetest.register_on_dieplayer(function(player, _)
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
	local auth = minetest.get_auth_handler().get_auth(target)
	local privs = minetest.get_player_privs(target)
	local privs_color = colorize_privs(target, data, privs)
	if data == nil then
		minetest.chat_send_player(name, C("#FF0000", S("[stats] Failed to load stats!")))
		return
	end

	local tags
	if minetest.get_player_by_name(target) then
		tags = C("#00BD00", S("[Online]"))
	else
		tags = C("#FF0000", S("[Offline]"))
	end
	if privs.staff then
		tags = tags .. " " .. C("#FF8800", S("[Staff]"))
	end

	-- Format some values
	local playtime = format_duration(data.playtime)
	local avg_playtime = format_duration(data.playtime / data.join_count)
	local first_join = os.date("!%Y-%m-%d %H:%M", data.first_join) .. " UTC"
	local free_votes = archtec.free_votes - data.free_votes

	local last_login
	if auth and auth.last_login and auth.last_login ~= -1 then
		last_login = os.date("!%Y-%m-%d %H:%M", auth.last_login) .. " UTC"
	else
		last_login = "unknown"
	end

	local xp = archtec_playerdata.calc_xp(data)

	-- Generate formspec
	local formspec = {
		"formspec_version[3]",
		"size[9,6]",
		"box[0.3,0.3;8.4,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. FS("Stats of: @1 - @2 XP @3", target, format_int(xp), tags) .. "]",

		"label[0.4,1.2;" .. FS("Nodes dug: @1", format_int(data.nodes_dug)) .. "]",
		"label[0.4,1.8;" .. FS("Nodes placed: @1", format_int(data.nodes_placed)) .. "]",
		"label[0.4,2.4;" .. FS("Crafted items: @1", format_int(data.items_crafted)) .. "]",
		"label[0.4,3.0;" .. FS("Died: @1", format_int(data.died)) .. "]",
		"label[0.4,3.6;" .. FS("Chatmessages: @1", format_int(data.chatmessages)) .. "]",
		"label[0.4,4.2;" .. FS("Thank you: @1", format_int(data.thank_you)) .. "]",
		"label[0.4,4.8;" .. FS("Playtime: @1", playtime) .. "]",
		"label[0.4,5.4;" .. FS("Average playtime: @1", avg_playtime) .. "]",

		"label[4.5,1.2;" .. FS("Join count: @1", format_int(data.join_count)) .. "]",
		"label[4.5,1.8;" .. FS("First join: @1", first_join) .. "]",
		"label[4.5,2.4;" .. FS("Last login: @1", last_login) .. "]",
		"label[4.5,3.0;" .. FS("Remaining free votes: @1", free_votes) .. "]",
		"label[4.5,3.6;" .. FS("Can spill lava: @1", privs_color.lava) .. "]",
		"label[4.5,4.2;" .. FS("Can use the chainsaw: @1", privs_color.chainsaw) .. "]",
		"label[4.5,4.8;" .. FS("Can forceload areas: @1", privs_color.forceload) .. "]",
		"label[4.5,5.4;" .. FS("Can create big areas: @1", privs_color.areas) .. "]",
	}

	minetest.show_formspec(name, "archtec_playerdata:stats", table.concat(formspec))
end

minetest.register_chatcommand("stats", {
	params = "<name>",
	description = S("Shows stats of <name>"),
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/stats] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = param:trim()
		if target == "" then
			target = name
		end
		if not minetest.player_exists(target) then
			minetest.chat_send_player(name, C("#FF0000", S("[stats] Unknown player!")))
			return
		end
		if target ~= name and archtec.ignore_check(name, target) then
			archtec.ignore_msg("stats", name, target)
			return
		end
		stats_formspec(name, target)
	end
})

-- XP stuff
local xp_rank = {
	min_xp = 100000, -- keeps list clean
	cache_period = 21600, -- 6h
	user_count = 0,
	all = 0,
	gentime = 0,
	list = {},
	names = {}, -- names top 3 players
}

function archtec_playerdata.calc_xp(data)
	local xp = 0
	xp = xp + (data.nodes_dug or 0) * 1
	xp = xp + (data.nodes_placed or 0) * 1.5
	xp = xp + (data.items_crafted or 0) * 0.5
	xp = xp - (data.died or 0) * 1000
	xp = xp + (data.playtime or 0) * 0.025 -- 0.025 xp per second = 90 XP per hour
	xp = xp + (data.chatmessages or 0) * 2
	xp = xp + (data.thank_you or 0) * 100
	return math.floor(xp)
end

local function generate_ranking()
	local users = {}
	local storage = archtec_playerdata.get_db()

	xp_rank.all = 0
	xp_rank.user_count = 0
	xp_rank.list = {}
	xp_rank.names = {}

	for key, data in pairs(storage) do
		local name = key:sub(8, #key) -- remove 'player_'
		local xp = archtec_playerdata.calc_xp(data)
		local color = archtec.namecolor.namecolor_refs[data.s_ncolor] or "#ffffff"
		xp_rank.all = xp_rank.all + xp
		xp_rank.user_count = xp_rank.user_count + 1

		if xp >= xp_rank.min_xp then
			users[name] = {name = name, xp = xp, color = color}
		end
	end

	-- Sort data (A > B)
	local sorted = {}
	for name, stats in pairs(users) do
		table.sort(stats, function(a, b) return a.xp > b.xp end)
		sorted[#sorted + 1] = {name, stats.xp}
	end
	table.sort(sorted, function(a, b) return a[2] > b[2] end)

	for i, entry in ipairs(sorted) do
		local name, xp = entry[1], entry[2]
		local color = users[name].color
		local str = i .. ". " .. name .. " - " .. format_int(xp) .. " XP"
		xp_rank.list[i] = color .. ",0," .. F(str)
		if i <= 3 then
			xp_rank.names[i] = name
		end
	end

	xp_rank.gentime = os.time()
end

local function rank_formspec(name)
	if xp_rank.gentime < os.time() - xp_rank.cache_period then
		generate_ranking()
	end

	local formspec = {
		"formspec_version[3]",
		"size[10,10]",
		"box[0.3,0.3;9.4,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. FS("Player ranking - @1 players earned @2 XP", xp_rank.user_count, format_int(xp_rank.all)) .. "]",
		"hypertext[3.5,1.2;3,1;;<center><mono>1st " .. F(xp_rank.names[1]) .. "</mono></center>]",
		"item_image[4,1.4;2,2;cups:cup_gold]",
		"hypertext[0,1.8;3,1;;<center><mono>2nd " .. F(xp_rank.names[2]) .. "</mono></center>]",
		"item_image[0.5,2.0;2,2;cups:cup_silver]",
		"hypertext[7,1.8;3,1;testid;<center><mono>3rd " .. F(xp_rank.names[3]) .. "</mono></center>]",
		"item_image[7.5,2.0;2,2;cups:cup_bronze]",
		"tablecolumns[color;tree;text]",
		"table[0.3,4.5;9.4,5.2;list;" .. table.concat(xp_rank.list, ",") .. ";0]",
	}

	minetest.show_formspec(name, "archtec_playerdata:ranking", table.concat(formspec))
end

minetest.register_chatcommand("rank", {
	description = S("Show the most active players"),
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/rank] executed by '" .. name .. "'")
		rank_formspec(name)
	end
})