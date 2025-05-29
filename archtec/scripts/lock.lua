local can_join = true

local function lock_server(mode, keep, locker)
	if mode == "new" then
		core.chat_send_all(core.colorize("#FF0000", locker .. " closed the server. Only staff members can join."))
		archtec_matterbridge.send(":lock: " .. archtec.escape_md(locker) .. " closed the server. Only staff members can join.")
		can_join = false
	elseif mode == "kick" then
		core.chat_send_all(core.colorize("#FF0000", locker .. " closed the server. Only staff members can join."))
		archtec_matterbridge.send(":lock: " .. archtec.escape_md(locker) .. " closed the server. Only staff members can join.")
		can_join = false
		for _, player in ipairs(core.get_connected_players()) do
			local name = player:get_player_name()
			if not archtec.table_contains(keep, name) and not core.get_player_privs(name).staff then
				core.kick_player(name, locker .. " closed the server. Only staff members can join.")
			end
		end
	end
end

local function open_server(opener)
	core.chat_send_all(core.colorize("#00BD00", opener .. " opened the server. Everyone can join again, including new players."))
	archtec_matterbridge.send(":unlock: " .. archtec.escape_md(opener) .. " opened the server. Everyone can join again, including new players.")
	can_join = true
end

core.register_on_prejoinplayer(function(name)
	if name and not can_join then
		if not core.get_player_privs(name).staff then
			core.chat_send_all(core.colorize("#FF0000", name .. " tried to connect, but the server is closed for anyone except staff members."))
			archtec_matterbridge.send(":no_entry: " .. archtec.escape_md(name) .. " tried to connect, but the server is closed for anyone except staff members.")
			return "The server is closed. Only staff members can join."
		end
	end
end)

core.register_chatcommand("lock", {
	description = "Lock the server",
	params = "<mode> [<keep (list of names)>]",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/lock] executed by '" .. name .. "' with param '" .. param .. "'")
		if not can_join then
			core.chat_send_player(name, core.colorize("#FF0000", "[lock] The server is already locked!"))
			return
		end
		if param:trim() == "" then
			core.chat_send_player(name, core.colorize("#FF0000", "[lock] No arguments provided!"))
			return
		end
		local mode, keep
		mode, keep = param:match("([^ ]+) *(.*)")
		keep = archtec.string_to_table(keep)
		lock_server(mode, keep, name)
		core.chat_send_player(name, core.colorize("#00BD00", "[lock] Locked the server successfully."))
	end
})

core.register_chatcommand("open", {
	description = "Opens the server",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/open] executed by '" .. name .. "'")
		if can_join then
			core.chat_send_player(name, core.colorize("#FF0000", "[open] The server is not locked!"))
			return
		end
		open_server(name)
		core.chat_send_player(name, core.colorize("#00BD00", "[open] Opened the server successfully."))
	end
})
