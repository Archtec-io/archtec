minetest.register_privilege("spawn", {
	description = "Allows player to teleport to spawn."
})

local function movePlayerToSpawn(playerName)
	local player = minetest.get_player_by_name(playerName)
	if player ~= nil then
		player:set_pos({x = 236.5, y = 16, z = -2033.5})
	end
end

local function movePlayerToOldSpawn(playerName)
	local player = minetest.get_player_by_name(playerName)
	if player ~= nil then
		player:set_pos({x = 325, y = 12, z = 1120})
	end
end

minetest.register_chatcommand("spawn", {
	privs = {spawn = true},
	func = movePlayerToSpawn
})

minetest.register_chatcommand("s", {
	privs = {spawn = true},
	func = movePlayerToSpawn
})

minetest.register_chatcommand("spawn_old", {
	privs = {spawn = true},
	func = movePlayerToOldSpawn
})

minetest.register_chatcommand("s_o", {
	privs = {spawn = true},
	func = movePlayerToOldSpawn
})
