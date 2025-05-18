local f = string.format

core.register_can_bypass_userlimit(function(name, ip)
	return core.check_player_privs(name, {staff = true})
end)

core.register_on_prejoinplayer(function(name, ip)
	archtec.notify_team(f("[login] (1) Connection initialisation by %s (IP: %s)", name, ip))
end)

core.register_on_authplayer(function(name, ip, is_success)
	archtec.notify_team(f("[login] (2) Authentication for %s (IP: %s) %s", name, ip, is_success and "succesful" or "failed"))
end)

core.register_on_leaveplayer(function(player, timed_out)
	archtec.notify_team(f("[logout] Connection to %s %s", player:get_player_name(), timed_out and "timed out" or "closed"))
end)
