minetest.register_can_bypass_userlimit(function(name, ip)
	return minetest.check_player_privs(name, {staff=true})
end)