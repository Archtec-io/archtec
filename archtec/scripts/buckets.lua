--based on https://github.com/wsor4035/liquid_restriction
--registering priv
minetest.register_privilege("adv_buckets", ("Able to use all liquids."))

local liquid_list = {
    "bucket:bucket_lava",
    "techage:bucket_oil",
}

--reads list, overrides nodes, adding priv check
local function override()
    for liquidcount = 1, #liquid_list do
        --checks if its a valid node/item
        if minetest.registered_items[liquid_list[liquidcount]] then
            --get old on_place behavior
            local old_place = minetest.registered_items[liquid_list[liquidcount]].on_place or function() end

            --override
            minetest.override_item(liquid_list[liquidcount], {
                on_place = function(itemstack, placer, pointed_thing)
                    local pname = placer:get_player_name()

                    if not minetest.check_player_privs(pname, "adv_buckets") then
                        minetest.chat_send_player(pname, "[Liquid Restriction]: 'adv_buckets' priv required to use this node")
                        return
                    else
                        return old_place(itemstack, placer, pointed_thing)
                    end
                end,
            })
        end
    end
end

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        if def.drawtype and (def.drawtype == "liquid" or def.drawtype == "flowingliquid")
        and minetest.get_item_group(name, "liquid_blacklist") == 0 then
            table.insert(liquid_list, name)
        end
    end

    override()
end)
