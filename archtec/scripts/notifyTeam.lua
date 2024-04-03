local server_running = false
local has_matterbridge = false

function notifyTeam(message, discord)
	minetest.log("action", message)

	if server_running then
		local colored_message = minetest.colorize("#999", message)
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if minetest.get_player_privs(name).staff then
				minetest.chat_send_player(name, colored_message)
			end
		end
	end

	if discord ~= false and has_matterbridge then
		archtec_matterbridge.send(message, "log")
	end
end

minetest.after(0, function()
	server_running = true
	if minetest.global_exists("archtec_matterbridge") then
		has_matterbridge = true
	end
end)