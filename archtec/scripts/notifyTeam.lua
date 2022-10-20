if minetest.get_modpath("chatplus_discord") then
    function notifyTeam(message)
        for _, online_players in ipairs(online_players) do
            local name = player:get_player_name()
            if name then
                local hasPrivs = minetest.check_player_privs(name, "staff")
                if hasPrivs then
                    minetest.chat_send_player(name, message)
                end
            end
        end
        discord.send(message, "1002864057398870066")
    end
else
    function notifyTeam(message)
        for _, online_players in ipairs(online_players) do
            local name = player:get_player_name()
            if name then
                local hasPrivs = minetest.check_player_privs(name, "staff")
                if hasPrivs then
                    minetest.chat_send_player(name, message)
                end
            end
        end
    end
end
