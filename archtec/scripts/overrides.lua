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
