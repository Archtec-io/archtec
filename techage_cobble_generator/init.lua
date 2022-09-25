minetest.register_node("techage_cobble_generator:dry_ice", {
	description = ("Dry ice"),
	tiles = {"techage_cobble_generator_dry_ice.png"},
	is_ground_content = false,
	paramtype = "light",
	groups = {cracky = 3, slippery = 3},
	sounds = default.node_sound_ice_defaults(),
	damage_per_second = 3
})

local function cool_lava (pos, node)
	if node.name == "default:lava_source" then
		minetest.set_node(pos, {name = "default:obsidian"})
	else
		minetest.set_node(pos, {name = "default:stone"})
	end
	minetest.sound_play("default_cool_lava",
		{pos = pos, max_hear_distance = 16, gain = 0.2}, true)
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
	end,
})
