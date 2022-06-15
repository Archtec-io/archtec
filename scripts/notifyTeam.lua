function notifyTeam(logMessage)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if name then
            local hasPrivs, missingPrivs = minetest.check_player_privs(name, "moderate")
            if hasPrivs then
                minetest.chat_send_player(name, logMessage)
            end
        end
    end
end