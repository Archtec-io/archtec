minetest.register_chatcommand("discord", {
	description = "Discord server link",
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/discord] executed by '" .. name .. "'")
		minetest.chat_send_player(name, "Discord server link: https://discord.gg/txCMTMwBWm")
	end
})
