archtec_chat = {
	user = {},
	users = {},
	channels = {}
}

archtec_chat.channel = dofile(core.get_modpath("archtec_chat") .. "/channels.lua")

archtec_chat.channel.create("main", {owner = "", public = true})
archtec_chat.channel.create("staff", {owner = "", public = false, secured = true})

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	archtec_chat.user.open(name)
	archtec_chat.channel.join("main", name, "")

	if core.get_player_privs(name).staff then
		archtec_chat.channel.join("staff", name, "")
	end
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	archtec_chat.user.save(name)
end)
