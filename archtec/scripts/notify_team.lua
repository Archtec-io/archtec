local server_running = false
local has_matterbridge = false

function archtec.notify_team(message, discord)
	core.log("action", message)

	if server_running then
		local colored_message = core.colorize("#999", message)
		for _, player in ipairs(core.get_connected_players()) do
			local name = player:get_player_name()
			if core.get_player_privs(name).staff then
				core.chat_send_player(name, colored_message)
			end
		end
	end

	if discord ~= false and has_matterbridge then
		archtec_matterbridge.send(message, "log")
	end
end

core.after(0, function()
	server_running = true
	if core.global_exists("archtec_matterbridge") then
		has_matterbridge = true
	end
end)
