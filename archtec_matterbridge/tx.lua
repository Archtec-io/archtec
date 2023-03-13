local http = ...

-- normal message in chat channel
discord.send = function(playername, message, channel, event)
	http.fetch({
		url = archtec_matterbridge.url .. "/api/message",
		method = "POST",
		extra_headers = {
			"Content-Type: application/json",
			"Authorization: Bearer " .. archtec_matterbridge.token
		},
		timeout = 5,
		data = minetest.write_json({
			gateway = channel or "main",
			username = playername,
			text = message,
			event = event
		})
	}, function()
		-- ignore errors
	end)
end

-- /me message in chat channel
minetest.override_chatcommand("me", {
	func = function(name, param)
		minetest.chat_send_all("* " .. name .. " " .. param)
		discord.send(nil, ":speech_left: " .. ('%s *%s*'):format(name, param))
		return true
	end
})

-- join player message
local old_join = minetest.send_join_message
function minetest.send_join_message(player_name)
	discord.send(nil, ":information_source: " .. player_name .. " joined the game.")
	old_join(player_name)
end

-- leave player message
local old_leave = minetest.send_leave_message
function minetest.send_leave_message(player_name, timed_out)
	if timed_out then
		discord.send(nil, ":information_source: " .. player_name .. " lost the connection...")
	else
		discord.send(nil, ":information_source: " .. player_name .. " left the game.")
	end
	old_leave(player_name, timed_out)
end

-- initial message on start
minetest.after(0.1, function()
	discord.send(nil, ":green_circle: Server is back online.")
end)

-- shutdown message
minetest.register_on_shutdown(function()
	discord.send(nil, ":warning: Server is shutting down...")
end)
