local S = archtec.S
local F = core.formspec_escape
local FS = function(...) return F(S(...)) end

local xp_rank = {
	min_xp = 100000,
	cache_period = archtec.time.hours(6),
	user_count = 0,
	all = 0,
	gentime = 0,
	list = {},
	names = {}, -- names top 3 players
}

function archtec.calc_xp(data)
	local xp = 0
	xp = xp + (data.nodes_dug or 0) * 1
	xp = xp + (data.nodes_placed or 0) * 1.5
	xp = xp + (data.items_crafted or 0) * 0.5
	xp = xp - (data.died or 0) * 1000
	xp = xp + (data.playtime or 0) * 0.025 -- 0.025 xp per second = 90 XP per hour
	xp = xp + (data.chatmessages or 0) * 2
	xp = xp + (data.thank_you or 0) * 100

	if xp < 0 then
		return 0
	end
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
		local xp = archtec.calc_xp(data)
		local color_def = archtec.namecolor.list[archtec.namecolor.get_idx(data.s_ncolor)] or {color = "#ffffff"}
		xp_rank.all = xp_rank.all + xp
		xp_rank.user_count = xp_rank.user_count + 1

		if xp >= xp_rank.min_xp then
			users[name] = {name = name, xp = xp, color = color_def.color}
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
		local str = i .. ". " .. name .. " - " .. archtec.format_int(xp) .. " XP"
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
		"label[0.4,0.55;" .. FS("Player ranking - @1 players earned @2 XP", xp_rank.user_count, archtec.format_int(xp_rank.all)) .. "]",
		"hypertext[3.5,1.2;3,1;;<center><mono>1st " .. F(xp_rank.names[1]) .. "</mono></center>]",
		"item_image[4,1.4;2,2;cups:cup_gold]",
		"hypertext[0,1.8;3,1;;<center><mono>2nd " .. F(xp_rank.names[2]) .. "</mono></center>]",
		"item_image[0.5,2.0;2,2;cups:cup_silver]",
		"hypertext[7,1.8;3,1;testid;<center><mono>3rd " .. F(xp_rank.names[3]) .. "</mono></center>]",
		"item_image[7.5,2.0;2,2;cups:cup_bronze]",
		"tablecolumns[color;tree;text]",
		"table[0.3,4.5;9.4,5.2;list;" .. table.concat(xp_rank.list, ",") .. ";0]",
	}

	core.show_formspec(name, "archtec_playerdata:ranking", table.concat(formspec))
end

core.register_chatcommand("rank", {
	description = S("Show the most active players"),
	privs = {interact = true},
	func = function(name)
		core.log("action", "[/rank] executed by '" .. name .. "'")
		rank_formspec(name)
	end
})
