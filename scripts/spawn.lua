minetest.register_privilege("spawn", {
	description = "Allows player to teleport to spawn."
})

minetest.register_chatcommand("spawn", {
	privs = { spawn = true },
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player ~= nil then
			player:set_pos({ x =-194, y = 10, z = 482 })
		end
	end
})