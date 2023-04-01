local http = ...
local sub = string.sub

local function handle_data(data)
	if not data or not data.username or not data.text or not data.gateway or not data.protocol or not data.userid then
		return
	end

	if data.event == "user_action" then
		minetest.log("action", "[archtec_matterbridge] User action '" .. data.text .. "' by '" .. data.username)
		minetest.chat_send_all("* " .. data.username .. " " .. data.text)
		discord.send(nil, ":speech_left: " .. ('%s *%s*'):format(data.username, data.text))
	elseif data.event == "join_leave" then
		return
		-- join/leave message, from irc for example; ignore
		-- discord.send(data.username, data.gateway, data.text)
	else
		-- regular text
		if sub(data.text, 1, 7) == "!status" then
			minetest.log("action", "[archtec_matterbridge] '" .. data.username .. "' requested the server status")
			minetest.chat_send_all(minetest.colorize("#FF8800", data.username) .. minetest.colorize("#666", " requested the server status via Discord."))
			discord.send(nil, minetest.get_server_status(nil, false))
		elseif sub(data.text, 1, 4) == "!cmd" then
			-- user command
			if not archtec_matterbridge.staff_user(data.username, data.userid) then
				minetest.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute a command via Discord. (Error: Only staff members can run commands)")
				minetest.chat_send_all(minetest.colorize("#FF8800", data.username) .. minetest.colorize("#666", " tried to execute a command via Discord. (Error: Only staff members can run commands.)"))
				discord.send(nil, "Error: Only staff members can run commands.")
				return
			end
			local commands = minetest.registered_chatcommands
			local raw = sub(data.text, 5)
			data.command, data.params = raw:match("([^ ]+) *(.*)")
			if data.params == nil or data.params == "" then -- no params; trim
				data.command = raw:trim()
			end
			-- Check if command exists
			if data.command == nil or commands[data.command] == nil then
				minetest.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute '" .. data.command .. (data.params or "") .. "' via Discord. (Error: Command does not exist.)")
				minetest.chat_send_all(minetest.colorize("#FF8800", data.username) .. minetest.colorize("#666", " tried to execute '/" .. data.command .. (data.params or "") .. "' via Discord. (Error: Command does not exist.)"))
				discord.send(nil, "Error: Command does not exist.")
				return
			end
			-- Check privileges
			local has_privs, missing_privs = minetest.check_player_privs(data.username, commands[data.command].privs or {})
			if not has_privs then
				local privs = table.concat(missing_privs, ", ")
				minetest.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute '" .. data.command .. (data.params or "") .. "' via Discord. (Error: Missing privileges: " .. (privs or "unknown") .. " )")
				minetest.chat_send_all(minetest.colorize("#FF8800", data.username) .. minetest.colorize("#666", " tried to execute '/" .. data.command .. (data.params or "") .. "' via Discord. (Error: Missing privileges: " .. (privs or "unknown") .. " )"))
				discord.send(nil, "Error: Missing privileges: " .. (privs or "unknown"))
				return
			end
			local old_chat_send_player = minetest.chat_send_player
			minetest.chat_send_player = function(name, message)
				old_chat_send_player(name, message)
				if name == data.username then
					local ret = minetest.get_translated_string("en", message)
					ret = minetest.strip_colors(ret)
					if sub(ret, 1, 9) == "[archtec]" or sub(ret, 1, 6) == "[xban]" then
						minetest.log("warning", "[archtec_matterbridge] Stopped possible notifyTeam leak '" .. ret .. "' (1)")
					else
						discord.send(nil, ret)
					end
				end
			end
			local _, ret_val = commands[data.command].func(data.username, data.params or "")
			if ret_val then
				old_chat_send_player(data.username, ret_val)
				local ret = minetest.get_translated_string("en", ret_val)
				ret = minetest.strip_colors(ret)
				if sub(ret, 1, 9) == "[archtec]" or sub(ret, 1, 6) == "[xban]" then
					minetest.log("warning", "[archtec_matterbridge] Stopped possible notifyTeam leak '" .. ret .. "' (2)")
				else
					discord.send(nil, ret)
				end
			end
			if data.params ~= nil then data.params = " " .. data.params end -- space between command and params
			if data.params == nil then data.params = "" end
			minetest.log("action", "[archtec_matterbridge] '" .. data.username .. "' executed '" .. data.command .. data.params .. "' via Discord")
			minetest.chat_send_all(minetest.colorize("#FF8800", data.username) .. minetest.colorize("#666", " executed '/" .. data.command .. data.params .. "' via Discord."))
			minetest.chat_send_player = old_chat_send_player
		else
			-- regular user message
			minetest.chat_send_all(minetest.colorize("#5662f6", "[Discord] ") .. minetest.colorize("#FF8800", data.username .. ": ") .. data.text)
		end
	end
end


local function recv_loop()
	http.fetch({
		url = archtec_matterbridge.url .. "/api/messages",
		extra_headers = {
			"Authorization: Bearer " .. archtec_matterbridge.token
		},
		timeout = 10,
	}, function(res)
		if res.succeeded and res.code == 200 and res.data and res.data ~= "" then
			local data = minetest.parse_json(res.data)
			if not data then
				minetest.log("error", "[archtec_matterbridge] content parsing error: " .. dump(res.data))
				return
			end

			if #data > 0 then
				-- array received
				for _, item in ipairs(data) do
					handle_data(item)
				end
			end
		else
			-- ignore errors
			minetest.log("error", "[archtec_matterbridge] http request to " .. archtec_matterbridge.url .. " failed with code " .. res.code)
		end

	end)
	-- re-schedule receive function in any case
	minetest.after(0.5, recv_loop)
end

-- start loop
minetest.after(1, recv_loop)
