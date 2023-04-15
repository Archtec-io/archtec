minetest.register_node("techage_cobble_generator:dry_ice", {
	description = ("Dry ice"),
	tiles = {"techage_cobble_generator_dry_ice.png"},
	is_ground_content = false,
	paramtype = "light",
	groups = {cracky = 3, slippery = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_ice_defaults(),
	damage_per_second = 3,
	drop = "techage_cobble_generator:dry_ice_cri"
})

local function cool_lava (pos, node)
	if node.name == "default:lava_source" then
		minetest.set_node(pos, {name = "default:obsidian"})
	else
		minetest.set_node(pos, {name = "default:stone"})
	end
	minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.2}, true)
end

minetest.register_abm({
	label = "Lava cooling (real cobble gen)",
	nodenames = {"default:lava_source", "default:lava_flowing"},
	neighbors = {"techage_cobble_generator:dry_ice"},
	interval = 3,
	chance = 2,
	catch_up = false,
	action = function(...)
		cool_lava(...)
	end
})

minetest.register_craftitem("techage_cobble_generator:diamond_powder", {
	description = ("Diamond Powder"),
	inventory_image = "techage_powder_inv.png^[colorize:#00FFFF:120",
	groups = {powder = 1},
})

minetest.register_craftitem("techage_cobble_generator:dry_ice_cri", {
	description = ("Dry ice"),
	inventory_image = "techage_cobble_generator_dry_ice.png",
	groups = {powder = 1},
	on_place = function(itemstack, placer, pt)
		local name = placer and placer:get_player_name() or ""

		-- check if pointing at a node
		if not pt or pt.type ~= "node" then
			return
		end

		local under = minetest.get_node(pt.under)

		local def = minetest.registered_nodes[under.name]
		if placer and itemstack and def and def.on_rightclick then
			return def.on_rightclick(pt.under, under, placer, itemstack, pt)
		end

		local above = minetest.get_node(pt.above)

		-- return if any of the nodes is not registered
		if not minetest.registered_nodes[under.name] or not minetest.registered_nodes[above.name] then
			return
		end

		-- if not protected then add node and remove 1 item from the itemstack
		if not minetest.is_protected(pt.above, name) then
			minetest.set_node(pt.above, {name = "techage_cobble_generator:dry_ice", param2 = 1})

			if placer and itemstack then
				itemstack:take_item()
			end

			return itemstack
		end
	end
})

techage.add_rinser_recipe({input = "techage:sieved_gravel", output = "techage_cobble_generator:diamond_powder", probability = 300})

techage.recipes.add("ta4_doser", {
	output = "techage_cobble_generator:dry_ice_cri 1",
	input = {
		"techage_cobble_generator:diamond_powder 5",
		"techage:water 3",
	}
})
