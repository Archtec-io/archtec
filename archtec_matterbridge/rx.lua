local http = ...
local C = core.colorize
local emojis = archtec_matterbridge.emojis

local protocol = {
	discord = "Discord",
	matrix = "Matrix"
}

local bridge_color = {
	discord = "#5662f6", -- Purple from discord icon
	matrix = "#2bc599" -- Green from element icon
}

local function handle_data(data)
	if not data or not data.username or not data.text or not data.protocol or not data.userid then
		return
	end
	local bridge = protocol[data.protocol]

	-- replace common emojis
	for emoji, name in pairs(emojis) do
		data.text = data.text:gsub(emoji, ":" .. name .. ":")
	end

	if data.event == "user_action" then
		core.log("action", "[archtec_matterbridge] User action '" .. data.text .. "' by '" .. data.username)
		core.chat_send_all("* " .. data.username .. " " .. data.text)
		archtec_matterbridge.send(":speech_left: " .. ('%s *%s*'):format(archtec.escape_md(data.username), data.text))
	else
		-- regular text
		if data.text:sub(1, 7) == "!status" then
			core.log("action", "[archtec_matterbridge] '" .. data.username .. "' requested the server status")
			core.chat_send_all(C("#FF8800", data.username) .. C("#999", " requested the server status via " .. bridge .. "."))
			archtec_matterbridge.send(archtec.escape_md(core.get_server_status(nil, false)))
		elseif data.text:sub(1, 4) == "!cmd" then
			-- user command
			if not archtec_matterbridge.staff_user(data.username, data.userid) then
				core.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute a command via " .. bridge .. ". (Error: Only staff members can run commands)")
				core.chat_send_all(C("#FF8800", data.username) .. C("#999", " tried to execute a command via " .. bridge .. ". (Error: Only staff members can run commands.)"))
				archtec_matterbridge.send("Error: Only staff members can run commands.")
				return
			end
			local commands = core.registered_chatcommands
			local raw = data.text:sub(5)
			data.command, data.params = raw:match("([^ ]+) *(.*)")
			if data.params == nil or data.params == "" then -- no params; trim
				data.command = raw:trim()
			end
			-- Check if command exists
			if data.command == nil or commands[data.command] == nil then
				core.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute '" .. data.command .. (data.params or "") .. "' via " .. bridge .. ". (Error: Command does not exist.)")
				core.chat_send_all(C("#FF8800", data.username) .. C("#999", " tried to execute '/" .. data.command .. (data.params or "") .. "' via " .. bridge .. ". (Error: Command does not exist.)"))
				archtec_matterbridge.send("Error: Command does not exist.")
				return
			end
			-- Check privileges
			local has_privs, missing_privs = core.check_player_privs(data.username, commands[data.command].privs or {})
			if not has_privs then
				local privs = table.concat(missing_privs, ", ")
				core.log("action", "[archtec_matterbridge] '" .. data.username .. "' tried to execute '" .. data.command .. (data.params or "") .. "' via " .. bridge .. ". (Error: Missing privileges: " .. (privs or "unknown") .. " )")
				core.chat_send_all(C("#FF8800", data.username) .. C("#999", " tried to execute '/" .. data.command .. (data.params or "") .. "' via " .. bridge .. ". (Error: Missing privileges: " .. (privs or "unknown") .. " )"))
				archtec_matterbridge.send("Error: Missing privileges: " .. (privs or "unknown"))
				return
			end
			local old_chat_send_player = core.chat_send_player
			core.chat_send_player = function(name, message)
				old_chat_send_player(name, message)
				if name == data.username then
					local ret = core.strip_colors(core.get_translated_string("en", message))
					if ret:sub(1, 9) == "[archtec]" or ret:sub(1, 6) == "[xban]" then
						core.log("warning", "[archtec_matterbridge] Stopped possible notify team leak '" .. ret .. "' (1)")
					else
						archtec_matterbridge.send(ret)
					end
				end
			end
			local _, ret_val = commands[data.command].func(data.username, data.params or "")
			if ret_val then
				old_chat_send_player(data.username, ret_val)
				local ret = core.strip_colors(core.get_translated_string("en", ret_val))
				if ret:sub(1, 9) == "[archtec]" or ret:sub(1, 6) == "[xban]" then
					core.log("warning", "[archtec_matterbridge] Stopped possible archtec notify team leak '" .. ret .. "' (2)")
				else
					archtec_matterbridge.send(ret)
				end
			end
			if data.params ~= nil and data.params ~= "" then data.params = " " .. data.params end -- space between command and params
			if data.params == nil then data.params = "" end
			core.log("action", "[archtec_matterbridge] '" .. data.username .. "' executed '" .. data.command .. data.params .. "' via " .. bridge)
			core.chat_send_all(C("#FF8800", data.username) .. C("#999", " executed '/" .. data.command .. data.params .. "' via " .. bridge .. "."))
			core.chat_send_player = old_chat_send_player
		else
			local text = data.text:gsub("\n", " ")
			-- regular user message
			core.log("action", "[archtec_matterbridge] CHAT (" .. bridge .. "): <" .. data.username .. "> " .. text)
			core.chat_send_all(C(bridge_color[data.protocol], "[" .. bridge .. "] ") .. C("#FF8800", data.username .. ": ") .. text)
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
			local data = core.parse_json(res.data)
			if not data then
				core.log("error", "[archtec_matterbridge] content parsing error: " .. dump(res.data))
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
			core.log("error", "[archtec_matterbridge] http request to " .. archtec_matterbridge.url .. " failed with code " .. res.code)
		end

	end)
	-- re-schedule receive function in any case
	core.after(0.5, recv_loop)
end

-- start loop
core.after(1, recv_loop)
