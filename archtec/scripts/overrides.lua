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