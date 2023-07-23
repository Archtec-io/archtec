local S = archtec.S

minetest.register_chatcommand("sd", {
	description = "Shuts the server down after a 10 seconds delay.",
	privs = { server = true },
	func = function(name, delay)
		if delay == "" or type(tonumber(delay)) ~= "number" then delay = 10 end
		-- notify all
		local logmsg = name .. " requested a server shutdown in " .. delay .. " seconds."
		minetest.log("warning", logmsg)
		discord.send(nil, ":anger: " .. logmsg)
		minetest.chat_send_all(minetest.colorize("#FF0", S("@1 requested a server shutdown in @2 seconds.", name, delay)))
		-- shutdown, ask for reconnect
		minetest.request_shutdown("The server is rebooting, please reconnect in about a minute.", true, tonumber(delay))
	end
})