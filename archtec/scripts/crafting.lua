if minetest.get_modpath("pride_flags") then
    minetest.clear_craft({
        output = "pride_flags:lower_mast"
    })
    minetest.register_craft({
        output = "pride_flags:lower_mast",
        recipe = {
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"}
        }
    })
end

--homedecor:table/ts_furniture:default_WOODTYPE_small_table
if minetest.get_modpath("homedecor_tables") then
    minetest.clear_craft({
        output = "homedecor:table"
    })
    minetest.register_craft({
        output = "homedecor:table",
        recipe = {
            { "group:wood","group:wood", "group:wood" },
            { "group:stick", "", "group:stick" },
            { "", "group:stick", "" }
        }
    })
end

--doors:prison_door (xdecor)/xpanes:door_steel_bar (xpanes)
if minetest.get_modpath("xpanes") then
    minetest.clear_craft({
        output = "xpanes:door_steel_bar"
    })
    minetest.register_craft({
        output = "xpanes:door_steel_bar",
		recipe = {
			{"xpanes:bar_flat", "default:steel_ingot"},
			{"default:steel_ingot", "xpanes:bar_flat"},
			{"xpanes:bar_flat", "default:steel_ingot"}
		}
    })
end

if minetest.get_modpath("ethereal") then
    minetest.register_craft({
        output = "ethereal:bowl",
        type = "shapeless",
        recipe = {"farming:bowl"}
    })

    minetest.register_craft({
    output = "farming:bowl",
    type = "shapeless",
    recipe = {"ethereal:bowl"}
    })
end

--jonez palace windows have the same recipe
if minetest.get_modpath("jonez") then
    minetest.clear_craft({
        output = "xpanes:palace_window_top_flat"
    })
    minetest.clear_craft({
        output = "xpanes:palace_window_bottom_flat"
    })
    minetest.register_craft({
        output = "xpanes:palace_window_top_flat",
		recipe = {
			{"xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat"},
			{"xpanes:pane_flat", "", "xpanes:pane_flat"}
		}
    })
    minetest.register_craft({
        output = "xpanes:palace_window_bottom_flat",
		recipe = {
			{"xpanes:pane_flat", "", "xpanes:pane_flat"},
			{"xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat"}
		}
    })
end

--xdecor
if minetest.get_modpath("xdecor") then
    minetest.clear_craft({
        output = "xdecor:pressure_stone_off"
    })
    minetest.register_craft({
        output = "xdecor:pressure_stone_off",
		recipe = {{"xdecor:stone_tile", "xdecor:stone_tile"}}
    })

    minetest.clear_craft({
        output = "xdecor:pressure_wood_off"
    })
    minetest.register_craft({
        output = "xdecor:pressure_wood_off",
		recipe = {{"xdecor:wood_tile", "xdecor:wood_tile"}}
    })

    minetest.clear_craft({
        output = "xdecor:tatami"
    })
    minetest.register_craft({
        output = "xdecor:tatami",
        recipe = {
            {"farming:wheat", "farming:wheat", "farming:wheat"},
            {"", "farming:wheat", ""}
        }
    })

    minetest.clear_craft({
        output = "xdecor:packed_ice"
    })
    minetest.register_craft({
        output = "xdecor:packed_ice",
        recipe = {
            {"ethereal:icebrick", "ethereal:icebrick"},
            {"ethereal:icebrick", "ethereal:icebrick"}
        }
    })

    minetest.clear_craft({
        output = "xdecor:bowl"
    })
    minetest.register_craft({
        output = "xdecor:bowl",
        recipe = {
            {"xdecor:wood_tile", "", "xdecor:wood_tile"},
            {"", "xdecor:wood_tile", ""}
        }
    })
end