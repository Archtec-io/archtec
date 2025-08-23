local http = ...
local is_shutdown = false

-- normal message in chat channel
archtec_matterbridge.send = function(message, channel, event)
	http.fetch({
		url = archtec_matterbridge.url .. "/api/message",
		method = "POST",
		extra_headers = {
			"Content-Type: application/json",
			"Authorization: Bearer " .. archtec_matterbridge.token
		},
		timeout = 5,
		data = core.write_json({
			gateway = channel or "luanti-post",
			text = message,
			event = event
		})
	}, function()
		-- ignore errors
	end)
end

-- /me message in chat channel
core.override_chatcommand("me", {
	func = function(name, param)
		local msg = archtec.get_and_trim(param)
		if msg ~= "" then
			core.chat_send_all("* " .. name .. " " .. param)
			archtec_matterbridge.send(":speech_left: " .. ('%s *%s*'):format(archtec.escape_md(name), param))
		else
			core.chat_send_player(name, core.colorize("#FF0000", "[/me] No message provided!"))
		end
		return true
	end
})

-- join player message
local old_join = core.send_join_message
function core.send_join_message(player_name)
	archtec_matterbridge.send(":information_source: " .. archtec.escape_md(player_name) .. " joined the game.")
	old_join(player_name)
end

-- leave player message
local old_leave = core.send_leave_message
function core.send_leave_message(player_name, timed_out)
	if archtec.silent_leave[player_name] then
		archtec.silent_leave[player_name] = nil
		return
	end
	if not is_shutdown then
		if timed_out then
			archtec_matterbridge.send(":information_source: " .. archtec.escape_md(player_name) .. " lost the connection.")
		else
			archtec_matterbridge.send(":information_source: " .. archtec.escape_md(player_name) .. " left the game.")
		end
	end
	old_leave(player_name, timed_out)
end

-- initial message on start
core.after(0.1, function()
	archtec_matterbridge.send(":green_circle: Server is back online.")
end)

-- shutdown message
core.register_on_shutdown(function()
	is_shutdown = true
	archtec_matterbridge.send(":warning: Server is shutting down...")
end)
