minetest.register_privilege("spawn", {
    description = "Allows to teleport players to spawn"
})

minetest.register_chatcommand("spawn", {
    privs = {spawn=true},  
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player ~= nil then
            player:set_pos({x=-194,y=10,z=482})
        end
    end
})

local path = minetest.get_modpath("archtec")

dofile(path .. "/scripts/notifyTeam.lua")
dofile(path .. "/scripts/userlimit.lua")
dofile(path .. "/scripts/inv_move.lua")
dofile(path .. "/scripts/stats.lua")
dofile(path .. "/scripts/shutdown.lua")
dofile(path .. "/scripts/mapfix.lua")
dofile(path .. "/scripts/prejoin.lua")
dofile(path .. "/scripts/disallow_new_players.lua")
dofile(path .. "/scripts/unknown.lua")
dofile(path .. "/scripts/unregister.lua")
dofile(path .. "/scripts/rezepte.lua")

minetest.register_alias("myblocks:brick", "graystone:brick")