local function break_warning(itemstack, user, node, digparams)
    if not user then return itemstack end
    local name = user:get_player_name()
    local wdef = itemstack:get_definition()
    if not minetest.is_creative_enabled(name) then
        itemstack:add_wear(digparams.wear)
        if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
            minetest.sound_play(wdef.sound.breaks, {
                pos = node.pos,
                gain = 0.5
            }, true)
        end
    end
    if itemstack:get_wear() > 60135 then
        minetest.chat_send_player(name, minetest.colorize("#FF0000", "Your tool is about to break!"))
        minetest.sound_play("default_tool_breaks", {
            to_player = name,
            gain = 2.0,
        }, true)
    end
    return itemstack
end

minetest.register_on_mods_loaded(function()
    for _, tool in pairs(minetest.registered_tools) do
        if string.sub(tool.name, 1, 8) == "default:" or
            string.sub(tool.name, 1, 9) == "ethereal:" or
            string.sub(tool.name, 1, 8) == "farming:" or
            string.sub(tool.name, 1, 9) == "moreores:" or
            string.sub(tool.name, 1, 9) == "titanium:" or
            string.sub(tool.name, 1, 8) == "techage:"
        then
            if not tool.after_use then
                minetest.override_item(tool.name, {
                    after_use = break_warning
                })
            end
        end
    end
end)