if minetest.get_modpath("home_workshop_machines") then
    minetest.register_craft({
        type = "shaped",
        output = "home_workshop_machines:3dprinter_bedflinger",
        recipe = {
            {"", "dye:black", ""},
            {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
            {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
        }
    })
    
    minetest.register_craft({
        type = "shaped",
        output = "home_workshop_machines:3dprinter_corexy",
        recipe = {
            {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
            {"default:steel_ingot", "default:glass", "default:steel_ingot"},
            {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
        }
    })  
end

