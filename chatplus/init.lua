local S = core.get_translator("chatplus")
local C = core.colorize

local last_msg_name = {}

local msg_chat_color_text = "#ffff88"
local msg_chat_color_name = "#ffff00"

archtec_playerdata.register_key("chatmessages", "number", 0)

-- Hard depend chatplus on archtec mod to run archtec's on_chat_message callbacks (HACK)
core.register_on_chat_message(function(name, message)
	-- Priv check
	if not core.get_player_privs(name).shout then
		core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] You don't have the shout priv!")))
		core.log("action", "CHAT: <" .. name .. "> " .. message .. " (player does not have 'shout')")
		return true
	end

	-- 7msg typo check
	if message:sub(1, 4) == "7msg" then
		core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] Anti leak detection blocked this message!")))
		core.log("action", "CHAT: <" .. name .. "> " .. message .. " (blocked by anti leak detection)")
		return true
	end

	-- Channelname resolver
	local cc = archtec.count_keys(archtec_chat.users[name].channels)
	local channel

	-- User set default channel
	local default_channel = archtec_chat.users[name].default
	if default_channel then
		if archtec_chat.channels[default_channel] and archtec_chat.channels[default_channel].users[name] then
			channel = default_channel
		end
	end

	-- Use is in only one channel, select this
	if cc == 1 then
		channel = next(archtec_chat.users[name].channels)
	end

	-- Guess channel by pattern matching
	if message:sub(1, 1) == "#" then
		local cname, msg = string.match(message, "^#(%S+) ?(.*)")
		cname = archtec_chat.channel.get_cname(cname)
		if not cname then
			core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] No channelname provided!")))
			return true
		end
		if msg == "" then
			core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] Don't forget to add a message!")))
			return true
		end
		if archtec_chat.channels[cname] and archtec_chat.channels[cname].users[name] then
			channel = cname
			message = msg
		else
			core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] #@1 does not exist or you aren't a channel member!", cname)))
			return true
		end

	-- Fallback to 'main'
	elseif archtec_chat.users[name].channels.main and channel == nil then -- normal message
		channel = "main"
	end

	-- No channel available
	if not channel then
		core.chat_send_player(name, core.colorize("#FF0000", S("[chatplus] You aren't in any channel! (try '/c j main')")))
		return true
	end

	-- Use 'main' channel
	if channel == "main" then
		local msg = core.colorize(archtec.namecolor.get(name), name .. ": ") .. message
		core.log("action", "CHAT: <" .. name .. "> " .. message)

		local cdef = archtec_chat.channel.get_cdef("main")
		for uname, _ in pairs(cdef.users) do
			-- Do not send messages to blocked players
			if not archtec.ignore_check(name, uname) then
				core.chat_send_player(uname, msg)
			end
		end
		archtec_matterbridge.send(("**%s**: %s"):format(archtec.escape_md(name), message))

	-- Handle custom channel
	else
		core.log("action", "CHAT: <" .. name .. "> " .. message .. " (#" .. channel .. ")")
		archtec_chat.channel.send(channel, name .. ": " .. message, name)
	end

	archtec_playerdata.mod(name, "chatmessages", 1)
	return true
end)

local function private_message(name, param)
	local to, msg = string.match(param, "([%a%d_-]+) (.+)")
	if to == nil or msg == nil then
		core.chat_send_player(name, C("#FF0000", S("[msg] Usage: '/msg <name> <msg>'!")))
		return
	end
	if not core.get_player_by_name(to) then
		core.chat_send_player(name, C("#FF0000", S("[msg] Player '@1' isn't online!", to)))
		return
	end
	if name == to then
		core.chat_send_player(name, C("#FF0000", S("[msg] You can't send yourself a msg!")))
		return
	end
	if archtec.ignore_check(name, to) then
		core.log("action", "MSG: from <" .. name .. "> to <" .. to .. "> " .. msg .. " (message blocked by ignore)")
		archtec.ignore_msg("msg", name, to)
		return
	end
	core.chat_send_player(name, C(msg_chat_color_name, S("To") .. " " .. to .. ": ") .. C(msg_chat_color_text, msg))
	core.chat_send_player(to, C(msg_chat_color_name, S("From") .. " " .. name .. ": ") .. C(msg_chat_color_text, msg))
	core.log("action", "MSG: from <" .. name .. "> to <" .. to .. "> " .. msg)
	core.sound_play("chatplus_incoming_msg", {to_player = to}, true)
	last_msg_name[name] = to
end

core.register_chatcommand("m", {
	description = S("Send a private message to the same person you sent your last message to."),
	func = function(name, param)
		local last_user = last_msg_name[name]
		if last_user == nil then
			core.chat_send_player(name, C("#FF0000", S("[msg] Can't use this command. Use '/msg <name> <msg>' first!")))
			return
		end
		if not archtec.is_online(last_user) then
			core.chat_send_player(name, C("#FF0000", S("[msg] @1 isn't online anymore!", last_user)))
			return
		end
		private_message(name, last_user .. " " .. param)
	end
})

core.unregister_chatcommand("msg")
core.register_chatcommand("msg", {func = private_message})

core.register_on_leaveplayer(function(player)
	last_msg_name[player:get_player_name()] = nil
end)
