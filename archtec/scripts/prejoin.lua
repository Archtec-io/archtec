local modName = minetest.get_current_modname()

minetest.register_on_prejoinplayer(function(name, ip)
	notifyTeam("["..modName.."] Connection initialisation by '"..name.."' (IP: "..ip..")")
end)
