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

--homedecor:table_legs_wood/ropes:ladder_wood
if minetest.get_modpath("ropes") then
    minetest.clear_craft({
        output = "ropes:ladder_wood"
    })
    minetest.register_craft({
        output = "ropes:ladder_wood",
        recipe = {
            {"group:stick", "", "group:stick"},
            {"group:stick", "", "group:stick"},
            {"group:stick", "group:stick", "group:stick"}
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

--moreoes does not add recipes due to "rare material" hoes being removed from Minetest Game
--https://github.com/minetest-mods/moreores/blob/3fe0ba8fcb3a19222c23c0d1b01a671df43d655c/init.lua#L219-L222
if minetest.get_modpath("farming") and minetest.get_modpath("moreores") then
	minetest.register_craft({
		output = "moreores:hoe_silver",
		recipe = {
			{"moreores:silver_ingot", "moreores:silver_ingot", ""},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})
	minetest.register_craft({
		output = "moreores:hoe_mithril",
		recipe = {
			{"moreores:mithril_ingot", "moreores:mithril_ingot", ""},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
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