--Stats Mod
--(C) 2013 PilzAdam, (C) 2022 Niklp

stats = {}
local playerstats = {}

stats.registered_stats = {}
local function stats.register_stat(def)
	table.insert(stats.registered_stats, def)
end

local function stats.set_stat(player, name, value)
	local pname = player
	if type(pname) ~= "string" then
		pname = player:get_player_name()
	end
	if not playerstats[pname] then
		playerstats[pname] = {}
	end
	playerstats[pname][name] = value
end

local function stats.increase_stat(player, name, value)
	local pname = player
	if type(pname) ~= "string" then
		pname = player:get_player_name()
	end
	if not playerstats[pname] then
		playerstats[pname] = {}
	end
	if not playerstats[pname][name] then
		playerstats[pname][name] = 0
	end
	playerstats[pname][name] = playerstats[pname][name] + value
end

local function stats.get_stat(player, name)
	local pname = player
	if type(pname) ~= "string" then
		pname = player:get_player_name()
	end
	if not playerstats[pname] then
		playerstats[pname] = {}
	end
	if not playerstats[pname][name] then
		playerstats[pname][name] = 0
	end
	return playerstats[pname][name]
end


stats.register_stat({
	name = "digged_nodes",
	description = function(value)
		return " - Digged nodes: "..value
	end,
})

stats.register_stat({
	name = "placed_nodes",
	description = function(value)
		return " - Placed nodes: "..value
	end,
})

stats.register_stat({
	name = "died",
	description = function(value)
		return " - Died: "..value
	end,
})

stats.register_stat({
	name = "played_time",
	description = function(time)
		time = math.floor(time)
		local timestring = "" .. (time%60) .. "s"
		time = math.floor(time/60)
		if time > 0 then
			timestring = (time%60) .. "m " .. timestring
		end
		time = math.floor(time/60)
		if time > 0 then
			timestring = (time%24) .. "h " .. timestring
		end
		time = math.floor(time/24)
		if time > 0 then
			timestring = time .. "d " .. timestring
		end
		return " - Time played: "..timestring
	end,
})

stats.register_stat({
	name = "crafted",
	description = function(value)
		return " - Crafted items: "..value
	end,
})

local file = io.open(minetest:get_worldpath().."/stats.txt", "r")
if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			playerstats = table
		else
			minetest.log("error", "Corrupted stats file")
		end
		file:close()
end

local function save_stats()
	local file = io.open(minetest:get_worldpath().."/stats.txt", "w")
	if file then
		file:write(minetest.serialize(playerstats))
		file:close()
	else
		minetest.log("error", "Can't save stats")
	end
end

local timer = 0
local timer2 = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	timer2 = timer2 + dtime
	
	if timer > 13 then
		for _,player in ipairs(minetest.get_connected_players()) do
			stats.increase_stat(player, "played_time", timer)
		end
		timer = 0
	end
	
	if timer2 > 26 then
		timer2 = 0
		save_stats()
	end
end)

minetest.register_on_shutdown(function() 
	save_stats()
end)

minetest.register_on_dignode(function(pos, oldnode, player)
	if player and player:is_player() then
		stats.increase_stat(player, "digged_nodes", 1)
	end
end)

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack)
	if player and player:is_player() then
		stats.increase_stat(player, "placed_nodes", 1)
	end
end)

minetest.register_on_dieplayer(function(player)
	stats.increase_stat(player, "died", 1)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	stats.increase_stat(player, "crafted", itemstack:get_count())
end)

minetest.register_chatcommand("stats", {
	params = "<name>",
	description = "Prints the stats of the player",
	privs = {},
	func = function(name, param)
		local playername = name
		local player = minetest.get_player_by_name(param)
		if player then
			playername = player:get_player_name()
		end
		
		minetest.chat_send_player(name, "Stats for "..playername..":")
		for _,def in ipairs(stats.registered_stats) do
			local value = stats.get_stat(playername, def.name)
			minetest.chat_send_player(name, def.description(value))
		end
	end,
})
