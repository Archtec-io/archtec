if minetest.get_modpath("digilines") then
    minetest.override_item("digilines:chest", {
        tiles = {
		    "default_chest_top.png" and "digiline_std.png",
		    "default_chest_top.png",
		    "default_chest_side.png",
		    "default_chest_side.png",
		    "default_chest_side.png",
		    "default_chest_front.png",
	    },
    })
end

if minetest.get_modpath("itemframes") then
	minetest.override_item("itemframes:pedestal", {
		tiles = {"itemframes_pedestal_new.png"},
    })
end

if minetest.get_modpath("fireworkz") then
	minetest.override_item("fireworkz:launcher", {
		groups = {cracky = 2},
    })
end

if minetest.get_modpath("fake_fire") then
	minetest.override_item("fake_fire:fancy_fire", {
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			return itemstack
		end,
	})
end

if minetest.get_modpath("ethereal") then
	minetest.override_item("ethereal:golden_apple", {
		on_use = function(itemstack, user, pointed_thing)
			if user then
				user:set_hp(20)
				return minetest.do_item_eat(20, nil, itemstack, user, pointed_thing)
			end
		end,
	})
end

-- remove torch damage
if minetest.get_modpath("3d_armor") then
	minetest.override_item("default:torch", {damage_per_second = 0})
	minetest.override_item("default:torch_wall", {damage_per_second = 0})
	minetest.override_item("default:torch_ceiling", {damage_per_second = 0})
end
