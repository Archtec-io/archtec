function archtec.get_target(name, param)
	local target = param:trim()
	if target == "" or type(target) ~= "string" then
		target = name
	end
	return target
end

function archtec.is_online(name)
	local player = core.get_player_by_name(name)
	if not player then
		return false
	end
	return true
end

function archtec.priv_grant(name, priv)
	local privs = core.get_player_privs(name)
	privs[priv] = true
	core.set_player_privs(name, privs)
end

function archtec.priv_revoke(name, priv)
	local privs = core.get_player_privs(name)
	privs[priv] = nil
	core.set_player_privs(name, privs)
end

archtec.silent_leave = {}

function core.kick_player(player_name, reason)
	if type(reason) == "string" then
		reason = "Kicked: " .. reason
	else
		reason = "Kicked."
	end
	if archtec.is_online(player_name) then -- xban kicks also offline players
		core.chat_send_all(core.colorize("#FF0000", player_name .. " got kicked! Reason: " .. reason))
		archtec_matterbridge.send(":bangbang: " .. archtec.escape_md(player_name) .. " got kicked! Reason: " .. reason)
		archtec.silent_leave[player_name] = true
	end
	return core.disconnect_player(player_name, reason)
end

function archtec.kick_inactive_player(player_name)
	core.chat_send_all(core.colorize("#FF0000", player_name .. " got kicked due to inactivity."))
	archtec_matterbridge.send(":zzz: " .. archtec.escape_md(player_name) .. " got kicked due to inactivity.")
	archtec.silent_leave[player_name] = true
	return core.disconnect_player(player_name, "Too long inactive")
end

function archtec.split_itemname(itemname)
	local delimpos = string.find(itemname, ":")
	return itemname:sub(1, delimpos - 1), itemname:sub(delimpos + 1, #itemname)
end

function archtec.string_to_table(str, delim)
	assert(type(str) == "string")
	delim = delim or ","
	local table = {}
	for _, name in pairs(string.split(str, delim)) do
		table[name:trim()] = name:trim()
	end
	return table
end

local f = math.floor

function archtec.get_block_bounds(pos)
	local p1 = vector.new((f(pos.x/16))*16,(f(pos.y/16))*16,(f(pos.z/16))*16)
	local p2 = vector.new((f(pos.x/16))*16+15,(f(pos.y/16))*16+15,(f(pos.z/16))*16+15)
	return p1, p2
end

function archtec.count_keys(table)
	local c = 0
	for _ in pairs(table) do
		c = c + 1
	end
	return c
end

function archtec.table_contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function archtec.register_chatcommand_alias(newname, original)
	local cmd = table.copy(core.registered_chatcommands[original])
	if cmd then
		core.register_chatcommand(newname, cmd)
		core.registered_chatcommands[newname].mod_origin = core.registered_chatcommands[original].mod_origin
	end
end

function archtec.get_and_trim(string)
	if string and type(string) == "string" then
		return string:trim()
	end
	return ""
end

function archtec.parse_params(param)
	local params = {}
	for p in string.gmatch(param, "[^%s]+") do
		table.insert(params, p)
	end
	return params
end

function archtec.keys_to_string(keys, delim)
	local list = {}
	delim = delim or ", "
	for key, _ in pairs(keys) do
		list[#list + 1] = key
	end
	return table.concat(list, delim)
end

archtec.time = {}

function archtec.time.minutes(minutes)
	return 60 * minutes
end

function archtec.time.hours(hours)
	return 60 * 60 * hours
end

function archtec.time.days(days)
	return 60 * 60 * 24 * days
end

-- Attachments are a fucking mess
function archtec.is_attached(player)
	local name = player:get_player_name()
	if player_api.player_attached[name] == true then -- not all mods set this param
		return true
	elseif player:get_attach() ~= nil then -- not all mods use object attachments
		return true
	elseif player:get_meta():get_int("player_physics_locked") == 1 then -- some joe7575 mods set this
		return true
	elseif player:get_physics_override().speed == 0 then -- we probably don't want to move the player in this case
		return true
	else
		return false
	end
end

function archtec.format_int(number)
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Undescores are used for markdown formatting (mostly meant for player names)
function archtec.escape_md(str)
	local str_escaped, _ = str:gsub("_", "\\_")
	return str_escaped
end
