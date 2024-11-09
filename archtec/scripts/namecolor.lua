archtec.namecolor = {}

local list = {
	{id = "1", name = "Dark Blue", color = "#0000aa"},
	{id = "2", name = "Dark Green", color = "#00aa00"},
	{id = "3", name = "Dark Aqua", color = "#00aaaa"},
	{id = "4", name = "Dark Red", color = "#aa0000"},
	{id = "5", name = "Dark Purple", color = "#aa00aa"},
	{id = "6", name = "Gold", color = "#ffaa00"},
	{id = "7", name = "Grey", color = "#aaaaaa"},
	{id = "8", name = "Dark Grey", color = "#555555"},
	{id = "a", name = "Green", color = "#55ff55"},
	{id = "b", name = "Aqua", color = "#55ffff"},
	{id = "c", name = "Red", color = "#ff5555"},
	{id = "d", name = "Light Purple", color = "#ff55ff"},
	{id = "e", name = "Yellow", color = "#ffff55"},
}
archtec.namecolor.list = list

local list_names = {}
do
	for i, def in ipairs(list) do
		list_names[i] = def.name
	end
end
archtec.namecolor.list_names = list_names

local function get_idx(id)
	for i, def in ipairs(list) do
		if id == def.id then
			return i
		end
	end
end
archtec.namecolor.get_idx = get_idx

archtec_playerdata.register_key("s_ncolor", "string", "")
function archtec.namecolor.get(name)
	local id = archtec_playerdata.get(name, "s_ncolor")

	-- Migrate from player meta
	if id == "" then
		local player = core.get_player_by_name(name)
		local meta = player:get_meta()
		id = meta:get_string("chatplus:namecolor")
		-- Remove meta entry
		if id ~= "" then
			archtec_playerdata.set(name, "s_ncolor", id)
			meta:set_string("chatplus:namecolor", "")
		end
	end

	-- Choose random color if stored was removed (or not created yet)
	if id == "" or get_idx(id) == nil then
		id = list[math.random(1, #list)].id
		archtec_playerdata.set(name, "s_ncolor", id)
	end

	return list[get_idx(id)].color
end

-- This is important to generate/migrate data to give the settings access to it
core.register_on_joinplayer(function(player)
	archtec.namecolor.get(player:get_player_name())
end)
