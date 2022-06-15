minetest.register_on_prejoinplayer (function name, ip)
	local logMessage = 0
	minetest.log("action", "Player " .. name .. " prejoins from " .. ip)
	logMessage = ("Player: "..name.." prejoins")
	function notifyTeam(logMessage)
end
