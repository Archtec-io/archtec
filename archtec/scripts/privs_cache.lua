local hit_count = 0
local miss_count = 0

local cache = {}

local old_get_player_privs = minetest.get_player_privs
minetest.get_player_privs = function(name)
	local privs = cache[name]
	if privs == nil then
		miss_count =  miss_count + 1
		if type(name) == "string" then
			privs = old_get_player_privs(name)
			cache[name] = privs
		else
			local d = debug.getinfo(2, "nS")
			minetest.log("error", "[archtec] called 'get_player_privs' with wrong data type '" .. type(name) .. "' called from " .. (d.source or "") .. "@" .. (d.linedefined or ""))
			privs = {}
		end
	else
		hit_count = hit_count + 1
	end

	return privs
end

-- invalidation on set_privs and leave-player
local old_set_player_privs = minetest.set_player_privs
minetest.set_player_privs = function(name, privs)
	cache[name] = privs
	old_set_player_privs(name, privs);
end

minetest.register_on_leaveplayer(function(player)
	cache[player:get_player_name()] = nil
end)

minetest.register_chatcommand("privs_cache", {
	description = "Get privs cache debug info",
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/privs_cache] executed by '" .. name .. "'")
		minetest.chat_send_player(name, "Hit: " .. hit_count .. ", Miss: " .. miss_count)
	end
})
