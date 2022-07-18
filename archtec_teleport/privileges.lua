local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_privilege("archtec_teleport", {
	description = S("Let players teleport to other players (request will be sent)"),
})
