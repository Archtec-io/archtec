minetest.register_on_cheat(function(player, cheat)
    if not player:is_player() then return end
    local logMessage = "[archtec] Anticheat: player '" .. player:get_player_name() .. "' ('" .. cheat.type .. "')"
    notifyTeam(minetest.colorize("#666", logMessage))
end)
