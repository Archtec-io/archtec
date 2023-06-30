local function break_warning(itemstack, user, node, digparams)
    if not user then return itemstack end
    local name = user:get_player_name()
    local wdef = itemstack:get_definition()
    if not minetest.is_creative_enabled(name) then
        itemstack:add_wear(digparams.wear)
        if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
            minetest.sound_play(wdef.sound.breaks, {
                to_player = name,
                pos = node.pos,
                gain = 0.5
            }, true)
        end
    end
    if itemstack:get_wear() > 60135 and wdef.sound and wdef.sound.breaks then
        if archtec_playerdata.get(name, "s_tbw_show") then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "Your tool is about to break!"))
            minetest.sound_play(wdef.sound.breaks, {
                to_player = name,
                gain = 2.0,
            }, true)
        end
    end
    return itemstack
end

local function blacklisted(tool)
    if string.sub(tool, 1, 8) == "3d_armor" or
        string.sub(tool, 1, 15) == "christmas_decor" or
        string.sub(tool, 1, 7) == "shields" then return false
    end
    return true
end

minetest.register_on_mods_loaded(function()
    for _, tool in pairs(minetest.registered_tools) do
        if not blacklisted(tool.name) then
            if tool.on_use then
                local old_on_use = minetest.registered_tools[tool.name].on_use
                minetest.override_item(tool.name, {
                    on_use = function(itemstack, user, pointed_thing)
                        local wdef = itemstack:get_definition()
                        if itemstack:get_wear() > 60135 and wdef.sound and wdef.sound.breaks then
                            local name = user:get_player_name()
                            if archtec_playerdata.get(name, "s_tbw_show") then
                                minetest.chat_send_player(name, minetest.colorize("#FF0000", "Your tool is about to break!"))
                                minetest.sound_play(wdef.sound.breaks, {
                                    to_player = name,
                                    gain = 2.0,
                                }, true)
                            end
                        end
                        return old_on_use(itemstack, user, pointed_thing)
                    end
                })
            elseif not tool.after_use then
                minetest.override_item(tool.name, {
                    after_use = break_warning
                })
            end
        end
    end
end)