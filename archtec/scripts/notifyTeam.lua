function notifyTeam(message, dc)
	minetest.log("action", message)
	local colored_message = minetest.colorize("#999", message)
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if name then
			if minetest.get_player_privs(name).staff then
				minetest.chat_send_player(name, colored_message)
			end
		end
	end
	if dc == false then return end
	if archtec_matterbridge.send then -- Matterbridge API maybe isn't initialized now (calling on server startup)
		archtec_matterbridge.send(message, "log")
	end
end
