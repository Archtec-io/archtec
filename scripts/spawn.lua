minetest.register_privilege("spawn", {
	description = "Allows player to teleport to spawn."
})

local function movePlayerToSpawn(playerName)
	local player = minetest.get_player_by_name(playerName)
	if player ~= nil then
		player:set_pos({ x =-194, y = 10, z = 482 })
	end
end

minetest.register_chatcommand("spawn", {
	privs = { spawn = true },
	func = movePlayerToSpawn
})

minetest.register_chatcommand("s", {
	privs = { spawn = true },
	func = movePlayerToSpawn
})