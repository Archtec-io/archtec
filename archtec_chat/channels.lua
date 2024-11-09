local channel = {}
local C = core.colorize
local S = core.get_translator(core.get_current_modname())

local max_channel_lenght = 15
local max_user_channels = 10

--[[
local cdef_default = {
	owner = "", -- The channel operator
	users = {}, -- All online users of the channel mapped by playername = true
	invites = {}, -- All currently runnung invites mapped by playername = expire-timestamp
	secured = false, -- Kicks non staff members after log out
	public = false, -- Allows everyone to join the channel w/o invite
}
]]--

local function get_cdef(cname)
	if not archtec_chat.channels[cname] then return nil end
	return archtec_chat.channels[cname]
end

channel.get_cdef = get_cdef

local function is_channel_owner(cdef, name)
	if cdef.owner == name then
		return true
	end
	if core.get_player_privs(name).staff then
		return true
	end
	return false
end

local function list_table(t)
	if next(t) == nil then
		return ""
	end
	return archtec.keys_to_string(t)
end

local function get_cname(c)
	if not c then return end
	if c:sub(1, 1) == "#" then
		return c:sub(2, #c)
	else
		return c
	end
end

channel.get_cname = get_cname

archtec_playerdata.register_key("channels", "table", {})
archtec_playerdata.register_upgrade("channels", "archtec_chat:channel_str_to_list", false, function(name, value)
	return core.deserialize(value)
end)

function archtec_chat.user.open(name)
	local data = archtec_playerdata.get(name, "channels")
	-- add missing sub tables
	if not data.channels then
		data.channels = {}
	end
	-- remove old channels
	for cname, _ in pairs(data.channels) do
		if not get_cdef(cname) then
			data.channels[cname] = nil
		end
	end
	-- cleanup default channel
	if not get_cdef(data.default) then
		data.default = nil
	end

	archtec_chat.users[name] = data

	-- join channels
	for cname, _ in pairs(data.channels) do
		channel.join(cname, name, "")
	end
end

function archtec_chat.user.save(name)
	-- Permanently leave secured channels
	for cname, _ in pairs(archtec_chat.users[name].channels) do
		local cdef = get_cdef(cname)
		if cdef.secured and not is_channel_owner(cdef, name) then
			channel.leave(cname, name, name .. " left secured channel until next invite.")
		end
	end

	-- Save channels
	archtec_playerdata.set(name, "channels", archtec_chat.users[name])

	-- Leave all remaining channels
	for cname, _ in pairs(archtec_chat.users[name].channels) do
		channel.leave(cname, name, "")
	end

	archtec_chat.users[name] = nil
end

function channel.send(cname, message, sender)
	-- core.log("action", "[archtec_chat] Send message '" .. message .. "' into channel '" .. cname .. "'")
	if message == "" then return end
	local cdef = get_cdef(cname)
	local msg = C("#FF8800", "#" .. cname .. " | " .. message)
	for name, _ in pairs(cdef.users) do
		if sender then
			if not archtec.ignore_check(sender, name) then -- don't send if ignored
				core.chat_send_player(name, msg)
			end
		else
			core.chat_send_player(name, msg)
		end
	end
end

function channel.create(cname, params)
	core.log("action", "[archtec_chat] Create channel '" .. cname .. "' for '" .. (params.owner or "") .. "'")
	local def = {
		owner = params.owner or "",
		public = params.public or false,
		secured = params.secured or false,
		users = {},
		invites = {},
	}
	archtec_chat.channels[cname] = def
end

function channel.delete(cname, name)
	core.log("action", "[archtec_chat] Delete channel '" .. cname .. "' by '" .. name .. "'")
	channel.send(cname, name .. " deleted the channel.")
	archtec_chat.channels[cname] = nil
end

function channel.join(cname, name, msg)
	local cdef = get_cdef(cname)
	cdef.users[name] = true
	if msg then
		channel.send(cname, msg)
	else
		channel.send(cname, name .. " joined the channel.")
	end
	archtec_chat.users[name].channels[cname] = true
end

function channel.leave(cname, name, msg)
	local cdef = get_cdef(cname)
	if msg then
		channel.send(cname, msg)
	else
		channel.send(cname, name .. " left the channel.")
	end
	cdef.users[name] = nil
	archtec_chat.users[name].channels[cname] = nil
	-- unset default channel
	if archtec_chat.users[name].default == cname then
		archtec_chat.users[name].default = nil
	end
end

function channel.invite_delete(cname, target, timed_out)
	local cdef = get_cdef(cname)
	if cdef.invites[target] then -- invite might already be deleted
		core.log("action", "[archtec_chat] Delete '" .. cname .. "' invite for '" .. target .. "'")
		if timed_out then
			core.chat_send_player(target, C("#FF8800", S("Invite timed-out.")))
		end
		cdef.invites[target] = nil
	end
end

function channel.invite(cname, target, inviter)
	local cdef = get_cdef(cname)
	core.log("action", "[archtec_chat] '" .. inviter .. "' invited '" .. target .. "' to channel '" .. cname .. "'")
	core.chat_send_player(target, C("#FF8800", S("@1 invited you to join #@2. '/c j @3' to join. It will timeout in 60 seconds. Type '/c l main' to leave the main channel.", inviter, cname, cname)))
	cdef.invites[target] = os.time()
	core.after(60, function(cname_new, target_new)
		local cdef_new = get_cdef(cname_new)
		if cdef_new and cdef_new.invites[target_new] then
			channel.invite_delete(cname_new, target_new, true)
		end
	end, cname, target)
end

function channel.invite_accept(cname, target)
	core.log("action", "[archtec_chat] Invite in '" .. cname .. "' accepted by '" .. target .. "'")
	channel.invite_delete(cname, target, false)
	channel.join(cname, target)
end

local help_list = {
	join = {
		name = "join",
		description = "Join or create a channel. Add 'public' to your command to make new the created channel public. Add 'default' to your command to make the new created channel your default channel. (# is optional)",
		param = "<channel> <public> <default>",
		shortcut = "j",
		usage = "/c join #mychannel {public} {default}"
	},
	leave = {
		name = "leave",
		description = "Leave a channel (# is optional)",
		param = "<channel>",
		shortcut = "l",
		usage = "/c leave #mychannel"
	},
	invite = {
		name = "invite",
		description = "Invite someone in a channel (# is optional)",
		param = "<channel> <name>",
		shortcut = "i",
		usage = "/c invite #mychannel Player007"
	},
	list = {
		name = "list",
		description = "List all channels",
		param = "",
		shortcut = "li",
		usage = "/c list"
	},
	find = {
		name = "find",
		description = "Finds all channels where <name> is",
		param = "<name>",
		shortcut = "f",
		usage = "/c find Player007"
	},
	kick = {
		name = "kick",
		description = "Kicks <name> from <channel>. Can be used by channelowners. (# is optional)",
		param = "<channel> <name>",
		shortcut = "k",
		usage = "/c kick #mychannel Player007"
	},
	help = {
		name = "help",
		description = "Sends you the help for <sub-command> (or all commands)",
		param = "<sub-command>",
		shortcut = "h",
		usage = "/c help join"
	},
	default = {
		name = "default",
		description = "Sets your default channel (# is optional)",
		param = "<channel>",
		shortcut = "d",
		usage = "/c default #mychannel"
	}
}

local tab = "	"

local function parse_help(d)
	local s = ""
	s = s .. "----------\n"
	s = s .. d.name .. ":\n"
	s = s .. tab .. S("Description: @1", d.description) .. "\n"
	s = s .. tab .. S("Params: @1", d.param) .. "\n"
	s = s .. tab .. S("Shortcut: @1", d.shortcut) .. "\n"
	s = s .. tab .. S("Usage: @1", d.usage) .. "\n"
	return s
end

local function help_all()
	local s = S("Archtec chat command reference") .. "\n"
	for _, d in pairs(help_list) do
		s = s .. parse_help(d)
	end
	return C("#00BD00", s)
end

core.register_chatcommand("c", {
	description = "Run '/c help' to get the command help",
	privs = {interact = true, shout = true},
	func = function(name, param)
		core.log("action", "[/c] executed by '" .. name .. "' with param '" .. param .. "'")
		if archtec.get_and_trim(param) == "" then
			core.chat_send_player(name, help_all())
			return
		end
		local params = archtec.parse_params(param)
		local action, p1, p2 = params[1], params[2], params[3]
		if action == "join" or action == "j" then
			local c = archtec.get_and_trim(p1)
			if c == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/join] No channelname provided!")))
				return
			end
			c = get_cname(c) -- remove channel prefix
			local cdef = get_cdef(c)
			-- join if main
			if c == "main" then
				channel.join(c, name, "")
				core.chat_send_player(name, C("#00BD00", S("[c/join] Joined #main.")))
				return
			end
			-- limit channels per user
			if #archtec_chat.users[name].channels >= max_user_channels then
				core.chat_send_player(name, C("#00BD00", S("[c/join] You can't be in more than @1 channels!", max_user_channels)))
				return
			end
			-- create if not registered
			if not cdef then
				local public = archtec.get_and_trim(params[3]) == "public" or archtec.get_and_trim(params[4]) == "public"
				local default_channel = archtec.get_and_trim(params[3]) == "default" or archtec.get_and_trim(params[4]) == "default"
				if type(c) == "string" and c:len() <= max_channel_lenght then
					channel.create(c, {owner = name, public = public})
					if public then
						channel.join(c, name, name .. " created the public channel.")
					else
						channel.join(c, name, name .. " created the channel.")
					end
					-- change default channel
					if default_channel then
						archtec_chat.users[name].default = c
						channel.send(c, "Set your default channel to " .. c)
					end
					return
				else
					core.chat_send_player(name, C("#FF0000", S("[c/join] Channelname contains forbidden characters or is too long!")))
					return
				end
			end
			-- check if player is already in channel
			if cdef.users[name] then
				core.chat_send_player(name, C("#FF0000", S("[c/join] You are already in this channel!")))
				return
			end
			-- is player invited?
			local is_owner = is_channel_owner(cdef, name)
			if cdef.invites[name] or is_owner or cdef.public then
				if cdef.invites[name] then
					channel.invite_accept(c, name)
				else
					channel.join(c, name)
				end
			else
				core.chat_send_player(name, C("#FF0000", S("[c/join] You aren't invited!")))
				return
			end
		elseif action == "leave" or action == "l" then
			local c = archtec.get_and_trim(p1)
			if c == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/leave] No channelname provided!")))
				return
			end
			c = get_cname(c) -- remove channel prefix
			local cdef = get_cdef(c)
			-- leave if main
			if c == "main" then
				channel.leave(c, name, "")
				core.chat_send_player(name, C("#00BD00", S("[c/leave] Left #main.")))
				return
			end
			-- check if player is in channel
			if not cdef or not cdef.users[name] then
				core.chat_send_player(name, C("#FF0000", S("[c/leave] You are not in this channel!")))
				return
			end
			channel.leave(c, name)
		elseif action == "list" or action == "li" then
			local channels = archtec_chat.channels
			if next(channels) == nil then
				core.chat_send_player(name, C("#FF0000", S("No channels registered!")))
				return
			end
			local list = S("[c/list] Active channels:") .. "\n"
			for cname, cdef in pairs(channels) do
				list = list .. cname .. " - " .. list_table(cdef.users or {}) .. "\n"
			end
			list = list:sub(1, #list - 1)
			core.chat_send_player(name, C("#00BD00", list))
		elseif action == "invite" or action == "i" then
			local c = archtec.get_and_trim(p1)
			local target = archtec.get_and_trim(p2)
			if c == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] No channelname provided!")))
				return
			end
			if target == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] No target provided!")))
				return
			end
			if name == target then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] You can't invite yourself!")))
				return
			end
			if not archtec.is_online(target) then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] @1 is not online!", target)))
				return
			end
			c = get_cname(c) -- remove channel prefix
			local cdef = get_cdef(c)
			if not cdef then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] Channel #@1 does not exist!", c)))
				return
			end
			if not is_channel_owner(cdef, name) then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] You aren't authorized to invite someone to join @1!", c)))
				return
			end
			if not cdef.users[name] then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] You can't invite @1 since you aren't in #@2!", target, c)))
				return
			end
			if cdef.users[target] then
				core.chat_send_player(name, C("#FF0000", S("[c/invite] @1 is already a member of #@2!", target, c)))
				return
			end
			if archtec.ignore_check(name, target) then
				archtec.ignore_msg("c/invite", name, target)
				return
			end
			channel.invite(c, target, name)
			core.chat_send_player(name, C("#00BD00", S("[c/invite] Invited @1 to join #@2.", target, c)))
		elseif action == "kick" or action == "k" then
			local c = archtec.get_and_trim(p1)
			local target = archtec.get_and_trim(p2)
			if c == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/kick] No channelname provided!")))
				return
			end
			if target == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/kick] No target provided!")))
				return
			end
			c = get_cname(c) -- remove channel prefix
			local cdef = get_cdef(c)
			if not cdef then
				core.chat_send_player(name, C("#FF0000", S("[c/kick] Channel #@1 does not exist!", c)))
				return
			end
			if not is_channel_owner(cdef, name) then
				core.chat_send_player(name, C("#FF0000", S("[c/kick] You aren't authorized to kick someone!")))
				return
			end
			if not cdef.users[target] then
				core.chat_send_player(name, C("#FF0000", S("[c/kick] @1 is not in #@2!", target, c)))
				return
			end
			channel.leave(c, target, name .. " kicked " .. target .. ".")
		elseif action == "find" or action == "f" then
			local target = archtec.get_and_trim(p1)
			if target == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/find] No target provided!")))
				return
			end
			if not archtec.is_online(target) then
				core.chat_send_player(name, C("#FF0000", S("[c/find] @1 is not online!", target)))
				return
			end
			local channels = archtec_chat.users[target].channels
			if next(channels) == nil then
				core.chat_send_player(name, C("#FF0000", S("[c/find] @1 is in no channels!", target)))
				return
			end
			core.chat_send_player(name, C("#00BD00", S("[c/find] @1 is in the following channels: @2", target, list_table(channels or {}))))
		elseif action == "help" or action == "h" then
			local help = archtec.get_and_trim(p1)
			if help == "" then
				core.chat_send_player(name, help_all())
				return
			end
			local hd = help_list[help]
			if not hd then
				core.chat_send_player(name, C("#FF0000", S("[c/help] No help for this sub-command available!")))
				return
			end
			core.chat_send_player(name, C("#00BD00", parse_help(hd)))
		elseif action == "default" or action == "d" then
			local c = archtec.get_and_trim(p1)
			if c == "" then
				core.chat_send_player(name, C("#FF0000", S("[c/default] No channelname provided!")))
				return
			end
			c = get_cname(c) -- remove channel prefix
			local cdef = get_cdef(c)
			-- check if player is in channel
			if not cdef or not cdef.users[name] then
				core.chat_send_player(name, C("#FF0000", S("[c/default] You are not in this channel!")))
				return
			end
			if archtec_chat.users[name].default == c then
				core.chat_send_player(name, C("#FF0000", S("[c/default] #@1 is already your default channel!", c)))
				return
			end
			archtec_chat.users[name].default = c
			core.chat_send_player(name, C("#00BD00", S("[c/default] Set your default channel to #@1.", c)))
		else
			core.chat_send_player(name, C("#FF0000", S("[c] Unknown sub-command! (try '/c help')")))
		end
	end
})

return channel
