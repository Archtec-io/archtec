local can_join = true

local function lock_server(mode, keep, locker)
	if mode == "new" then
		minetest.chat_send_all(
			minetest.colorize("#FF0000", locker .. " closed the server. Only staff members can join.")
		)
		archtec_matterbridge.send(":lock: " .. locker .. " closed the server. Only staff members can join.")
		can_join = false
	elseif mode == "kick" then
		minetest.chat_send_all(
			minetest.colorize("#FF0000", locker .. " closed the server. Only staff members can join.")
		)
		archtec_matterbridge.send(":lock: " .. locker .. " closed the server. Only staff members can join.")
		can_join = false
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if not archtec.table_contains(keep, name) and not minetest.get_player_privs(name).staff then
				minetest.kick_player(name, locker .. " closed the server. Only staff members can join.")
			end
		end
	end
end

local function open_server(opener)
	minetest.chat_send_all(
		minetest.colorize("#00BD00", opener .. " opened the server. Everyone can join again, including new players.")
	)
	archtec_matterbridge.send(
		":unlock: " .. opener .. " opened the server. Everyone can join again, including new players."
	)
	can_join = true
end

minetest.register_on_prejoinplayer(function(name)
	if name and not can_join then
		if not minetest.get_player_privs(name).staff then
			minetest.chat_send_all(
				minetest.colorize(
					"#FF0000",
					name .. " tried to connect, but the server is closed for anyone except staff members."
				)
			)
			archtec_matterbridge.send(
				":no_entry: " .. name .. " tried to connect, but the server is closed for anyone except staff members."
			)
			return "The server is closed. Only staff members can join."
		end
	end
end)

minetest.register_chatcommand("lock", {
	description = "Lock the server",
	params = "<mode> [<keep (list of names)>]",
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/lock] executed by '" .. name .. "' with param '" .. param .. "'")
		if not can_join then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "[lock] The server is already locked!"))
			return
		end
		if param:trim() == "" then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "[lock] No arguments provided!"))
			return
		end
		local mode, keep
		mode, keep = param:match("([^ ]+) *(.*)")
		keep = archtec.string_to_table(keep)
		lock_server(mode, keep, name)
		minetest.chat_send_player(name, minetest.colorize("#00BD00", "[lock] Locked the server successfully."))
	end,
})

minetest.register_chatcommand("open", {
	description = "Opens the server",
	privs = {staff = true},
	func = function(name)
		minetest.log("action", "[/open] executed by '" .. name .. "'")
		if can_join then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "[open] The server is not locked!"))
			return
		end
		open_server(name)
		minetest.chat_send_player(name, minetest.colorize("#00BD00", "[open] Opened the server successfully."))
	end,
})
