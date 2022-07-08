local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_privilege("tpr", {
	description = S("Let players teleport to other players (request will be sent)"),
	give_to_admin = true,
})

minetest.register_privilege("tp_admin", {
	description = S("Gives full admin-access to a player."),
	give_to_admin = true,
})