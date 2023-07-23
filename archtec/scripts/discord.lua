local S = archtec.S
archtec.discord_link = "https://discord.gg/txCMTMwBWm"

minetest.register_chatcommand("discord", {
	description = "Discord server link",
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/discord] executed by '" .. name .. "'")
		minetest.chat_send_player(name, S("Discord server link: @1", archtec.discord_link))
	end
})
