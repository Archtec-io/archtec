local current = {}

local key = "archtec:playtime"

function archtec.get_session_playtime(name)
	if current[name] then
		return os.time() - current[name]
	else
		return 0
	end
end

function archtec.get_total_playtime(name)
	local player = minetest.get_player_by_name(name)
	if player then
		return archtec_playerdata.get(name, "playtime") + archtec.get_session_playtime(name)
	end
end

function archtec.playtimesave(name)
	archtec_playerdata.mod(name, "playtime", archtec.get_session_playtime(name))
	current[name] = os.time()
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	current[name] = nil
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	current[name] = os.time()
	minetest.after(1, function()
		if player:is_player() then
			local meta = player:get_meta()
			if archtec_playerdata.get(name, "playtime") == 0 then
				archtec_playerdata.set(name, "playtime", player:get_meta():get_int(key))
				print(archtec_playerdata.get(name, "playtime"))
				meta:set_string(key, nil) -- remove playtime entry
				minetest.log("warning", "[archtec_playerdata] removed playtime meta of '" .. name .. "'")
			end
		end
	end)
end)
