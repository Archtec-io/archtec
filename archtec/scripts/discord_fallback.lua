if not minetest.get_modpath("chatplus_discord") then
    discord.send = function(...)
		-- dummy function to not crash the server when 'chatplus_discord' isn't available
	end
end
