local server_running = false

-- discord might be both bool or a string
function archtec.notify_team(message, discord)
	if not server_running then
		return
	end

	core.log("action", message)

	local colored_message = core.colorize("#999", message)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		if core.get_player_privs(name).staff then
			core.chat_send_player(name, colored_message)
		end
	end

	if type(discord) == "string" then
		archtec_matterbridge.send(archtec.escape_md(discord), "log")
	elseif discord ~= false then
		archtec_matterbridge.send(archtec.escape_md(message), "log")
	end
end

core.after(0, function()
	server_running = true
end)
