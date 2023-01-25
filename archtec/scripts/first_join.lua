local key = "archtec:joined"

minetest.register_on_joinplayer(function(player)
	minetest.after(1, function()
		if player:is_player() then
			local name = player:get_player_name()
			local meta = player:get_meta()
    		if meta:get_string(key) ~= "" then -- move legacy data
				archtec_playerdata.set(name, "joined", meta:get_string(key))
	    		meta:set_string(key, nil)
    		end
			if archtec_playerdata.get(name, "joined") == 0 then
				archtec_playerdata.set(name, "joined", os.date())
			end	
		end
	end)
end)

function archtec.get_first_join_date(name)
	local player = minetest.get_player_by_name(name)
	if player then
		return archtec_playerdata.get(name, "joined")
	end
end
