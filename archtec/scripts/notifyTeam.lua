function notifyTeam(message)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if name then
            local hasPrivs, missingPrivs = minetest.check_player_privs(name, "server")
            if hasPrivs then
                minetest.chat_send_player(name, message)
            end
        end
    end
    discord.send(message, "1002864057398870066")
end