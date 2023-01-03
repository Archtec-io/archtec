minetest.register_on_prejoinplayer(function(name, ip)
	notifyTeam("[archtec] Connection initialisation by '" .. name .. "' (IP: " .. ip .. ")")
end)
