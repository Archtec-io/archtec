if minetest.get_modpath("pride_flags") then
    minetest.clear_craft({
        output = "pride_flags:lower_mast"
    })
    minetest.register_craft({
        output = "pride_flags:lower_mast",
        recipe = {
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"},
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
            {"group:stick", "group:stick", "group:stick"},
        }
    })
end
