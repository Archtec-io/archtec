local function fix_craft(node, recipedef, amount)
	if not node or not recipedef then
		return
	end

	if amount == nil or amount < 1 then
		amount = 1
	end

	if not core.registered_nodes[node] and not core.registered_items[node] then
		core.log("warning", "[archtec] tried to override recipe of non exist item '" .. node .. "'")
		return
	end

	core.clear_craft({
		output = node
	})

	core.register_craft({
		output = node .. " " .. amount,
		recipe = recipedef
	})

	core.log("action", "[archtec] changed recipe of '" .. node .. "'")
end

-- pride_flags:lower_mast/bridger:bridges_steel_rod
fix_craft("pride_flags:lower_mast", {
	{"default:steel_ingot", "farming:string"},
	{"default:steel_ingot", "farming:string"},
	{"default:steel_ingot", "farming:string"}
})

-- homedecor:table/ts_furniture:default_WOODTYPE_small_table
fix_craft("homedecor:table", {
	{"group:wood","group:wood", "group:wood"},
	{"group:stick", "", "group:stick"},
	{"", "group:stick", ""}
})

-- xdecor:pressure_stone_off/mesecons_pressureplates:pressure_plate_stone_off
fix_craft("xdecor:pressure_stone_off", {
	{"xdecor:stone_tile", "xdecor:stone_tile"}
})

-- xdecor:pressure_wood_off/mesecons_pressureplates:pressure_plate_wood_off
fix_craft("xdecor:pressure_wood_off", {
	{"xdecor:wood_tile", "xdecor:wood_tile"}
})

-- xdecor:tatami/homedecor:tatami_mat
fix_craft("xdecor:tatami", {
	{"farming:wheat", "farming:wheat", "farming:wheat"},
	{"", "farming:wheat", ""}
})

-- xdecor:bowl/farming:bowl
fix_craft("xdecor:bowl", {
	{"xdecor:wood_tile", "", "xdecor:wood_tile"},
	{"", "xdecor:wood_tile", ""}
})

if core.get_modpath("ethereal") then
	core.register_craft({
		output = "ethereal:bowl",
		type = "shapeless",
		recipe = {"farming:bowl"}
	})

	core.register_craft({
		output = "farming:bowl",
		type = "shapeless",
		recipe = {"ethereal:bowl"}
	})
end

-- table_lamp and standing_lamp crafts are broken with UI https://github.com/mt-mods/homedecor_modpack/issues/39 *This is a hack
if core.get_modpath("homedecor_lighting") then
	core.register_craft({
		output = "homedecor:table_lamp_14",
		recipe = {
			{"wool:white", "default:torch", "wool:white"},
			{"", "group:stick", ""},
			{"", "default:slab_wood_8", ""},
		},
	})

	unifieddyes.register_color_craft({
		output = "homedecor:table_lamp_14",
		palette = "extended",
		type = "shapeless",
		neutral_node = "homedecor:table_lamp_14",
		recipe = {
			"NEUTRAL_NODE",
			"MAIN_DYE"
		}
	})

	core.register_craft({
		output = "homedecor:standing_lamp_14",
		recipe = {
			{"homedecor:table_lamp_14"},
			{"group:stick"},
			{"group:stick"},
		},
	})

	unifieddyes.register_color_craft({
		output = "homedecor:standing_lamp_14",
		palette = "extended",
		type = "shapeless",
		neutral_node = "homedecor:standing_lamp_14",
		recipe = {
			"NEUTRAL_NODE",
			"MAIN_DYE"
		}
	})
end

-- https://github.com/Archtec-io/bugtracker/issues/58 (small hack)
core.register_craft({
	output = "farming:wheat 3",
	recipe = {{"farming:straw"}}
})

-- https://github.com/Archtec-io/bugtracker/issues/181 and https://github.com/Archtec-io/bugtracker/issues/224
core.clear_craft({
	recipe = {{"castle_farming:bound_straw"}},
})

-- default:dry_dirt + group:water_bucket -> default:dirt (https://github.com/Archtec-io/bugtracker/issues/139)
core.register_craft({
	output = "default:dirt",
	type = "shapeless",
	recipe = {
		"group:water_bucket",
		"default:dry_dirt",
	},
	replacements = {{"group:water_bucket", "bucket:bucket_empty"}},
})
