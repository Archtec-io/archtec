local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_chatcommand("tpr", {
	description = S("Request teleport to another player"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, archtec_teleport = true},
	func = archtec_teleport.tpr_send
})

minetest.register_chatcommand("tp2me", {
	description = S("Request player to teleport to you"),
	params = S("<playername> | leave playername empty to see help message"),
	privs = {interact = true, archtec_teleport = true},
	func = archtec_teleport.tp2me_send
})

minetest.register_chatcommand("ok", {
	description = S("Accept teleport requests from another player"),
	privs = {interact = true, archtec_teleport = true},
	func = archtec_teleport.tpr_accept
})
