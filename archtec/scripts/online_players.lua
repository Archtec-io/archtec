online_players = {}

minetest.register_on_joinplayer(function(player)
	online_players[player:get_player_name()] = player
end)

minetest.register_on_leaveplayer(function(player)
	online_players[player:get_player_name()] = nil
end)
