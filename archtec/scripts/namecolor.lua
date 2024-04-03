archtec.namecolor = {}

local namecolors = {"1", "2", "3", "4", "5", "6", "7", "8", "a", "b", "c", "d", "e"}

local namecolor_names = {}
namecolor_names["1"] = "Dark Blue"
namecolor_names["2"] = "Dark Green"
namecolor_names["3"] = "Dark Aqua"
namecolor_names["4"] = "Dark Red"
namecolor_names["5"] = "Dark Purple"
namecolor_names["6"] = "Gold"
namecolor_names["7"] = "Grey"
namecolor_names["8"] = "Dark Grey"
namecolor_names["a"] = "Green"
namecolor_names["b"] = "Aqua"
namecolor_names["c"] = "Red"
namecolor_names["d"] = "Light Purple"
namecolor_names["e"] = "Yellow"
archtec.namecolor.names = namecolor_names

local namecolor_refs = {}
namecolor_refs["1"] = "#0000aa"
namecolor_refs["2"] = "#00aa00"
namecolor_refs["3"] = "#00aaaa"
namecolor_refs["4"] = "#aa0000"
namecolor_refs["5"] = "#aa00aa"
namecolor_refs["6"] = "#ffaa00"
namecolor_refs["7"] = "#aaaaaa"
namecolor_refs["8"] = "#555555"
namecolor_refs["a"] = "#55ff55"
namecolor_refs["b"] = "#55ffff"
namecolor_refs["c"] = "#ff5555"
namecolor_refs["d"] = "#ff55ff"
namecolor_refs["e"] = "#ffff55"

local namecolor_idxs = {}
local namecolor_list_human = {}

do
	for _, id in ipairs(namecolors) do
		table.insert(namecolor_list_human, namecolor_names[id])
		table.insert(namecolor_idxs, id)
	end
end

archtec.namecolor.namecolors = namecolors
archtec.namecolor.namecolor_refs = namecolor_refs
archtec.namecolor.idxs = namecolor_idxs
archtec.namecolor.list_human = namecolor_list_human

function archtec.namecolor.get_idx(color)
	for i, color_name in ipairs(namecolors) do
		if color_name == color then
			return i
		end
	end
end

archtec_playerdata.register_key("s_ncolor", "string", "")
function archtec.namecolor.get(name)
	local color = archtec_playerdata.get(name, "s_ncolor")

	-- Migrate from player meta
	if color == "" then
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()
		color = meta:get_string("chatplus:namecolor")
		-- Remove meta entry
		if color ~= "" then
			archtec_playerdata.set(name, "s_ncolor", color)
			meta:set_string("chatplus:namecolor", "")
		end
	end

	-- Choose random color if stored was removed (or not created yet)
	if color == "" or color == "0" or color == "9" then
		color = namecolors[math.random(1, 13)]
		archtec_playerdata.set(name, "s_ncolor", color)
	end

	return namecolor_refs[color]
end

-- This is important to generate/migrate data to give the settings access to it
minetest.register_on_joinplayer(function(player)
	archtec.namecolor.get(player:get_player_name())
end)