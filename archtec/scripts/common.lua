function archtec.get_target(name, param)
    local target = param:trim()
    if target == "" or target == nil or type(target) ~= "string" then
        target = name
    end
    return target
end

function archtec.is_online(name)
    local player = minetest.get_player_by_name(name)
    if not player then
        return false
    end
    return true
end

function archtec.grant_priv(name, priv)
    local privs = minetest.get_player_privs(name)
    privs[priv] = true
    minetest.set_player_privs(name, privs)
end

function archtec.revoke_priv(name, priv)
    local privs = minetest.get_player_privs(name)
    privs[priv] = nil
    minetest.set_player_privs(name, privs)
end

archtec.silent_leave = {}
function core.kick_player(player_name, reason)
    if type(reason) == "string" then
        reason = "Kicked: " .. reason
    else
        reason = "Kicked."
    end
    if archtec.is_online(player_name) then -- xban kicks also offline players
        minetest.chat_send_all(minetest.colorize("#FF0000", player_name .. " got kicked! Reason: " .. reason))
        discord.send(nil, ":bangbang: " .. player_name .. " got kicked! Reason: " .. reason)
        archtec.silent_leave[player_name] = true
    end
    return core.disconnect_player(player_name, reason)
end

function archtec.split_itemname(itemname)
    local delimpos = string.find(itemname, ":")
    return itemname:sub(1,  delimpos - 1), itemname:sub(delimpos + 1, #itemname)
end

function archtec.string_to_table(str, delim)
	assert(type(str) == "string")
	delim = delim or ','
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
    for k, _ in pairs(table) do
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
    local cmd = minetest.registered_chatcommands[original]
    if cmd then
        minetest.register_chatcommand(newname, cmd)
    end
end

function archtec.get_and_trim(string)
    if string then
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