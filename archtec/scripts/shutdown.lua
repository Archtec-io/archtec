minetest.register_chatcommand("sd", {
	description = "Shuts the server down after a 10 seconds delay.",
	privs = { server = true },
	func = function(playerName, delay)
		if delay == '' or type(tonumber(delay)) ~= "number" then delay = 10 end
		local logStr = playerName .. " requested a server shutdown in " .. delay .. " seconds."
		minetest.log("warning", logStr)
		minetest.chat_send_all(minetest.colorize("#FF0", logStr))
		discord.send(nil, ":anger: " .. logStr)
		minetest.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, tonumber(delay))
	end
})