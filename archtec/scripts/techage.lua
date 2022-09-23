local old_on_place = minetest.registered_nodes["techage:forceload"].on_place or function() end
minetest.override_item("techage:forceload", {
    on_place = function(itemstack, placer, pointed_thing)
        local pname = placer:get_player_name()

        if not minetest.check_player_privs(pname, "forceload") then
            minetest.chat_send_player(pname, "[Forceload Restriction]: 'forceload' priv required to use this node")
            return
        else
            return old_on_place(itemstack, placer, pointed_thing)
        end
    end
})

local old_on_place = minetest.registered_nodes["techage:forceloadtile"].on_place or function() end
minetest.override_item("techage:forceloadtile", {
    on_place = function(itemstack, placer, pointed_thing)
        local pname = placer:get_player_name()

        if not minetest.check_player_privs(pname, "forceload") then
            minetest.chat_send_player(pname, "[Forceload Restriction]: 'forceload' priv required to use this node")
            return
        else
            return old_on_place(itemstack, placer, pointed_thing)
        end
    end
})
