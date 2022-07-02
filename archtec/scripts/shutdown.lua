minetest.register_chatcommand("sd", {
	description = "Shuts the server down after a 10 seconds delay.",
	privs = { server = true },
	func = function(playerName, params)
		local logStr = playerName.." requested a server shutdown in 10 seconds."
		minetest.log("warning", logStr)
		minetest.chat_send_all(minetest.colorize("#FF0", logStr))
		discord.send(":anger: "..logStr)
		minetest.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, 10)
	end
})