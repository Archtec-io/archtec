local treebox = {
	type = "fixed",
	fixed = {{-0.8, -0.5, -0.8, 0.8, 2.5, 0.8}},
}

local wreathbox = {
	type = "fixed",
	fixed = {{-0.5, -0.5, 0.33, 0.5, 0.5, 0.5}},
}

local outdoortreebox = {
	type = "fixed",
	fixed = {{-1.448, -0.5, -1.448, 1.448, 4.5, 1.448}},
}

minetest.register_node("christmastree:indoortree", {
	description = "Indoor decorated Christmas Tree",
	drawtype = "mesh",
	paramtype = "light",
	light_source = 12,
	paramtype2 = "facedir",
	mesh = "indoor-christmas-tree.obj",
	tiles = {"christmastree_indoor_tree.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	selection_box = treebox,
	collision_box = treebox,
	use_texture_alpha = "clip",
})

minetest.register_node("christmastree:outdoortree", {
	description = "Outdoor decorated Christmas Tree",
	drawtype = "mesh",
	paramtype = "light",
	light_source = 12,
	paramtype2 = "facedir",
	mesh = "outdoor-christmas-tree.obj",
	tiles = {"christmastree_outdoor.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	selection_box = outdoortreebox,
	collision_box = outdoortreebox,
	use_texture_alpha = "clip",
})

minetest.register_node("christmastree:outdoortree_snow", {
	description = "Outdoor decorated Christmas Tree with snow",
	drawtype = "mesh",
	paramtype = "light",
	light_source = 12,
	paramtype2 = "facedir",
	mesh = "outdoor-christmas-tree.obj",
	tiles = {"christmastree_outdoor_snow.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	selection_box = outdoortreebox,
	collision_box = outdoortreebox,
	use_texture_alpha = "clip",
})

minetest.register_node("christmastree:christmas_wreath", {
	description = "Christmas Wreath",
	drawtype = "mesh",
	paramtype = "light",
	light_source = 12,
	paramtype2 = "facedir",
	mesh = "christmas-wreath.obj",
	tiles = {"christmastree_wreath.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	selection_box = wreathbox,
	collision_box = wreathbox,
	use_texture_alpha = "clip",
})

minetest.register_craft({
	output = "christmastree:indoortree",
	recipe = {
		{"", "default:gold_ingot", ""},
		{"", "default:sapling", ""},
		{"default:sapling", "default:sapling", "default:sapling"},
	},
})

minetest.register_craft({
	output = "christmastree:outdoortree",
	recipe = {
		{"", "default:sapling", ""},
		{"", "default:gold_ingot", ""},
		{"default:sapling", "default:sapling", "default:sapling"},
	},
})

minetest.register_craft({
	output = "christmastree:outdoortree_snow",
	recipe = {
		{"", "default:gold_ingot", ""},
		{"default:snow", "default:sapling", "default:snow"},
		{"default:sapling", "default:sapling", "default:sapling"},
	},
})

minetest.register_craft({
	output = "christmastree:christmas_wreath",
	recipe = {
		{"", "default:sapling", ""},
		{"default:sapling", "", "default:sapling"},
		{"", "default:sapling", ""},
	},
})
