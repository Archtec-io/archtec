local S = core.get_translator("techage_addon")

-- Register items
core.register_node("techage_addon:dry_ice", {
	description = S("Dry ice"),
	tiles = {"default_ice.png"},
	is_ground_content = false,
	paramtype = "light",
	groups = {cracky = 3, slippery = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_ice_defaults(),
	damage_per_second = 3,
	drop = "techage_addon:dry_ice_cri"
})
core.register_alias("techage_cobble_generator:dry_ice", "techage_addon:dry_ice")

core.register_craftitem("techage_addon:dry_ice_cri", {
	description = S("Dry ice"),
	inventory_image = core.inventorycube("default_ice.png", "default_ice.png", "default_ice.png"),
	groups = {powder = 1},
	on_place = function(itemstack, placer, pointed_thing)
		itemstack:set_name("techage_addon:dry_ice")
		local leftover = core.item_place(itemstack, placer, pointed_thing)
		leftover:set_name("techage_addon:dry_ice_cri")
		return leftover
	end
})
core.register_alias("techage_cobble_generator:dry_ice_cri", "techage_addon:dry_ice_cri")

core.register_craftitem("techage_addon:diamond_powder", {
	description = S("Diamond Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#00FFFF:120",
	groups = {powder = 1},
})
core.register_alias("techage_cobble_generator:diamond_powder", "techage_addon:diamond_powder")

-- Add to techage
techage.add_rinser_recipe({input = "techage:sieved_gravel", output = "techage_addon:diamond_powder", probability = 300})

techage.recipes.add("ta4_doser", {
	output = "techage_addon:dry_ice_cri 1",
	input = {
		"techage_addon:diamond_powder 5",
		"techage:water 3",
	}
})

-- Cool lava ABM
core.register_abm({
	label = "Lava cooling (real cobble gen)",
	nodenames = {"default:lava_source", "default:lava_flowing"},
	neighbors = {"techage_addon:dry_ice"},
	interval = 3,
	chance = 2,
	catch_up = false,
	action = function(pos, node)
		if node.name == "default:lava_source" then
			core.set_node(pos, {name = "default:obsidian"})
		else
			core.set_node(pos, {name = "default:stone"})
		end
		if math.random(1, 4) == 1 then
			core.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.2}, true)
		end
	end
})
