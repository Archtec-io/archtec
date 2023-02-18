function notifyTeam(message)
    minetest.log("action", message)
    local colored_message = minetest.colorize("#666", message)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if name then
            local has_privs = minetest.check_player_privs(name, "staff")
            if has_privs then
                minetest.chat_send_player(name, colored_message)
            end
        end
    end
    discord.send(nil, message, "log")
end
