core.register_on_prejoinplayer(function(name, ip)
	archtec.notify_team("[archtec] Connection initialisation by '" .. name .. "' (IP: " .. ip .. ")")
end)

core.register_can_bypass_userlimit(function(name, ip)
	return core.check_player_privs(name, {staff = true})
end)
