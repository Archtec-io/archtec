mapserver.bridge.add_players = function(data)
	data.players = {}

	for _, player in ipairs(minetest.get_connected_players()) do
		local is_moderator = minetest.check_player_privs(player:get_player_name(), {staff = true})

		local info = {
			name = player:get_player_name(),
			pos = player:get_pos(),
			hp = player:get_hp(),
			breath = player:get_breath(),
			velocity = player:get_velocity(),
			moderator = is_moderator,
			yaw = player:get_look_horizontal(),
			skin = nil,
		}

		table.insert(data.players, info)
	end
end
