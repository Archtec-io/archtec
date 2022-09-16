if minetest.get_modpath("pride_flags") then
    minetest.clear_craft({
        output="pride_flags:lower_mast"
    })
    minetest.register_craft({
        output="pride_flags:lower_mast",
        recipe={
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"},
            {"default:steel_ingot", "farming:string"},
        }
    })
end