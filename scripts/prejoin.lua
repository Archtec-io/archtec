local modName = minetest.get_current_modname()

minetest.register_on_prejoinplayer(function(name, ip)
	local logMessage = "["..modName.."] Connection initialisation by '"..name.."' (IP: "..ip..")"
	minetest.log("action", logMessage)
	notifyTeam(minetest.colorize("#666", logMessage))
	-- It's probably a better idea to just colorize everything inside the notifyTeam function.
end)
